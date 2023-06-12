defmodule Systems.Campaign.AssemblyTest do
  use CoreWeb.ConnCase

  import Mox
  alias Core.Repo
  alias CoreWeb.UI.Timestamp

  alias Systems.{
    Campaign,
    Assignment,
    Survey,
    Lab,
    Pool,
    Budget
  }

  setup_all do
    Mox.defmock(Systems.Campaign.AssemblyTest.UnsplashMockClient,
      for: Core.ImageCatalog.Unsplash.Client
    )

    Application.put_env(:core, :unsplash_client, Campaign.AssemblyTest.UnsplashMockClient)
    mock = Campaign.AssemblyTest.UnsplashMockClient

    {:ok, mock: mock}
  end

  setup do
    currency = Budget.Factories.create_currency("test_1234", :legal, "ƒ", 2)
    budget = Budget.Factories.create_budget("test_1234", currency)
    pool = Factories.insert!(:pool, %{name: "test_1234", director: :citizen, currency: currency})

    {:ok, currency: currency, budget: budget, pool: pool}
  end

  describe "campaign assembly" do
    alias Systems.Campaign

    setup [:login_as_researcher]

    test "create online", %{user: researcher, mock: mock, budget: budget, pool: pool} do
      mock
      |> expect(:get, fn _, "/photos/random", "query=abstract" ->
        {:ok,
         %{
           "urls" => %{"raw" => "http://example.org"},
           "user" => %{"username" => "tester", "name" => "Miss Test"},
           "blur_hash" => "asdf"
         }}
      end)

      campaign = Campaign.Assembly.create(researcher, "New Campaign", :online, pool, budget)

      assert %Systems.Campaign.Model{
               auth_node: %Core.Authorization.Node{
                 id: campaign_auth_node_id,
                 parent_id: nil
               },
               promotable_assignment:
                 %Systems.Assignment.Model{
                   director: :campaign,
                   assignable_experiment: %{
                     devices: [:phone, :tablet, :desktop],
                     duration: nil,
                     ethical_approval: nil,
                     ethical_code: nil,
                     language: nil,
                     subject_count: nil,
                     director: :campaign,
                     lab_tool_id: nil,
                     survey_tool: %Survey.ToolModel{
                       survey_url: nil,
                       director: :campaign,
                       auth_node: %Core.Authorization.Node{
                         parent_id: survey_tool_auth_node_parent_id
                       }
                     },
                     auth_node: %Core.Authorization.Node{
                       id: experiment_auth_node_id,
                       parent_id: experiment_auth_node_parent_id
                     }
                   },
                   auth_node: %Core.Authorization.Node{
                     id: assignment_auth_node_id,
                     parent_id: assignment_auth_node_parent_id
                   },
                   crew: %Systems.Crew.Model{
                     auth_node: %Core.Authorization.Node{
                       parent_id: crew_auth_node_parent_id
                     }
                   }
                 } = assignment,
               promotion: %Systems.Promotion.Model{
                 auth_node: %Core.Authorization.Node{
                   parent_id: promotion_auth_node_parent_id
                 },
                 banner_photo_url: banner_photo_url,
                 banner_subtitle: nil,
                 banner_title: banner_title,
                 banner_url: nil,
                 description: nil,
                 expectations: nil,
                 image_id:
                   "raw_url=http%3A%2F%2Fexample.org&username=tester&name=Miss+Test&blur_hash=asdf",
                 marks: ["vu"],
                 subtitle: nil,
                 director: :campaign,
                 themes: nil,
                 title: "New Campaign"
               }
             } = campaign

      assert promotion_auth_node_parent_id == campaign_auth_node_id
      assert assignment_auth_node_parent_id == campaign_auth_node_id
      assert experiment_auth_node_parent_id == assignment_auth_node_id
      assert crew_auth_node_parent_id == assignment_auth_node_id
      assert survey_tool_auth_node_parent_id == experiment_auth_node_id

      assert banner_photo_url == researcher.profile.photo_url
      assert banner_title == researcher.displayname

      # CAMPAIGN AUTHORS

      assert %{
               authors: [
                 %Systems.Campaign.AuthorModel{
                   campaign_id: campaign_id,
                   displayname: displayname,
                   fullname: fullname,
                   user_id: user_id,
                   user: %{
                     coordinator: nil,
                     displayname: og_displayname,
                     profile: %Core.Accounts.Profile{
                       fullname: og_fullname,
                       title: nil
                     },
                     researcher: true,
                     student: nil,
                     visited_pages: nil
                   }
                 }
               ]
             } = Campaign.Public.get!(campaign.id, authors: [user: [:profile]])

      assert campaign_id == campaign.id
      assert displayname == og_displayname
      assert fullname == og_fullname
      assert user_id == researcher.id

      # CAMPAIGN OWNER

      assert %Systems.Campaign.Model{
               auth_node: %Core.Authorization.Node{
                 role_assignments: [
                   %Core.Authorization.RoleAssignment{
                     principal_id: principal_id,
                     role: :owner
                   }
                 ]
               }
             } = Campaign.Public.get!(campaign.id, auth_node: [:role_assignments])

      assert principal_id === researcher.id

      owner = Assignment.Public.owner!(assignment)
      assert owner.id == researcher.id
    end

    test "create lab", %{user: researcher, mock: mock, budget: budget, pool: pool} do
      mock
      |> expect(:get, fn _, "/photos/random", "query=abstract" ->
        {:ok,
         %{
           "urls" => %{"raw" => "http://example.org"},
           "user" => %{"username" => "tester", "name" => "Miss Test"},
           "blur_hash" => "asdf"
         }}
      end)

      campaign = Campaign.Assembly.create(researcher, "New Campaign", :lab, pool, budget)

      assert %Systems.Campaign.Model{
               auth_node: %Core.Authorization.Node{
                 id: campaign_auth_node_id,
                 parent_id: nil
               },
               promotable_assignment: %Systems.Assignment.Model{
                 director: :campaign,
                 assignable_experiment: %{
                   devices: [],
                   duration: nil,
                   ethical_approval: nil,
                   ethical_code: nil,
                   language: nil,
                   subject_count: nil,
                   director: :campaign,
                   survey_tool_id: nil,
                   lab_tool: %Lab.ToolModel{
                     id: lab_tool_id,
                     director: :campaign,
                     auth_node: %Core.Authorization.Node{
                       parent_id: lab_tool_auth_node_parent_id
                     }
                   },
                   auth_node: %Core.Authorization.Node{
                     id: experiment_auth_node_id,
                     parent_id: experiment_auth_node_parent_id
                   }
                 },
                 auth_node: %Core.Authorization.Node{
                   id: assignment_auth_node_id,
                   parent_id: assignment_auth_node_parent_id
                 },
                 crew: %Systems.Crew.Model{
                   auth_node: %Core.Authorization.Node{
                     parent_id: crew_auth_node_parent_id
                   }
                 }
               }
             } = campaign

      assert Lab.Public.get_time_slots(lab_tool_id) == []

      assert assignment_auth_node_parent_id == campaign_auth_node_id
      assert experiment_auth_node_parent_id == assignment_auth_node_id
      assert crew_auth_node_parent_id == assignment_auth_node_id
      assert lab_tool_auth_node_parent_id == experiment_auth_node_id
    end

    test "delete", %{user: researcher, mock: mock, budget: budget, pool: pool} do
      mock
      |> expect(:get, fn _, "/photos/random", "query=abstract" ->
        {:ok,
         %{
           "urls" => %{"raw" => "http://example.org"},
           "user" => %{"username" => "tester", "name" => "Miss Test"},
           "blur_hash" => "asdf"
         }}
      end)

      %{id: id} = Campaign.Assembly.create(researcher, "New Campaign", :online, pool, budget)

      campaign = Campaign.Public.get!(id, Campaign.Model.preload_graph(:full))

      Campaign.Assembly.delete(campaign)

      assert Repo.get(Campaign.Model, campaign.id) == nil
      assert Repo.get(Systems.Promotion.Model, campaign.promotion_id) == nil
      assert Repo.get(Core.Authorization.Node, campaign.promotion.auth_node_id) == nil
      assert Repo.get(Systems.Assignment.Model, campaign.promotable_assignment_id) == nil
      assert Repo.get(Core.Authorization.Node, campaign.promotable_assignment.auth_node_id) == nil
      assert Repo.get(Systems.Crew.Model, campaign.promotable_assignment.crew_id) == nil

      assert Repo.get(Core.Authorization.Node, campaign.promotable_assignment.crew.auth_node_id) ==
               nil

      assert Repo.get(
               Survey.ToolModel,
               campaign.promotable_assignment.assignable_experiment.survey_tool_id
             ) ==
               nil

      assert Repo.get(
               Core.Authorization.Node,
               campaign.promotable_assignment.assignable_experiment.survey_tool.auth_node_id
             ) == nil
    end

    test "copy", %{user: researcher, mock: mock, budget: budget, pool: pool} do
      mock
      |> expect(:get, fn _, "/photos/random", "query=abstract" ->
        {:ok,
         %{
           "urls" => %{"raw" => "http://example.org"},
           "user" => %{"username" => "tester", "name" => "Miss Test"},
           "blur_hash" => "asdf"
         }}
      end)

      %{id: id} = Campaign.Assembly.create(researcher, "New Campaign", :online, pool, budget)

      %{
        id: id,
        submissions: [
          %{
            pool: %{name: pool_name}
          } = submission
        ],
        promotable_assignment: %{
          crew: crew1,
          assignable_experiment:
            %{
              survey_tool: tool
            } = experiment
        }
      } = Campaign.Public.get!(id, Campaign.Model.preload_graph(:full))

      # Update Submission
      reward_value = 1
      status = :submitted
      schedule_start = Timestamp.now() |> Timestamp.format_user_input_date()
      schedule_end = Timestamp.now() |> Timestamp.format_user_input_date()

      {:ok, %{submission: %{criteria: criteria}}} =
        Pool.Public.update(submission, %{
          reward_value: reward_value,
          status: status,
          schedule_start: schedule_start,
          schedule_end: schedule_end
        })

      genders = [:woman]
      dominant_hands = [:left]
      native_languages = [:en, :nl]

      # Update Criteria
      criteria
      |> Pool.CriteriaModel.changeset(%{
        genders: genders,
        dominant_hands: dominant_hands,
        native_languages: native_languages
      })
      |> Repo.update!()

      # Update Tool
      survey_url = "https://eyra.co/surveys/1"
      director = :campaign

      tool
      |> Survey.ToolModel.changeset(:update, %{
        survey_url: survey_url,
        director: director
      })
      |> Repo.update!()

      # Update Experiment
      subject_count = 2
      duration = "10"
      language = "en"
      ethical_approval = true
      ethical_code = "RERB"
      devices = [:desktop, :tablet]

      experiment
      |> Assignment.ExperimentModel.changeset(:update, %{
        subject_count: subject_count,
        duration: duration,
        language: language,
        ethical_approval: ethical_approval,
        ethical_code: ethical_code,
        devices: devices,
        director: director
      })
      |> Repo.update!()

      campaign = Campaign.Public.get!(id, Campaign.Model.preload_graph(:full))

      {:ok, %{campaign: %{id: id2}}} = Campaign.Assembly.copy(campaign)
      campaign2 = Campaign.Public.get!(id2, Campaign.Model.preload_graph(:full))

      assert %{
               authors: [%{}],
               auth_node: %{role_assignments: [%{role: :owner}]},
               submissions: [
                 %{
                   reward_value: nil,
                   schedule_end: ^schedule_end,
                   schedule_start: ^schedule_start,
                   criteria: %{
                     genders: ^genders,
                     dominant_hands: ^dominant_hands,
                     native_languages: ^native_languages
                   },
                   pool: %{
                     name: ^pool_name
                   },
                   status: :idle
                 }
               ],
               promotion: %{
                 title: "New Campaign (copy)"
               },
               promotable_assignment: %{
                 crew: crew2,
                 assignable_experiment: %{
                   subject_count: ^subject_count,
                   duration: ^duration,
                   language: ^language,
                   ethical_approval: ^ethical_approval,
                   ethical_code: ^ethical_code,
                   devices: ^devices,
                   director: ^director,
                   survey_tool: %{
                     survey_url: ^survey_url
                   }
                 }
               }
             } = campaign2

      assert crew1.id != crew2.id
    end
  end
end