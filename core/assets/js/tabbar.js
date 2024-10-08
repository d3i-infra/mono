let tabbarId = "";

export const Tabbar = {
  mounted() {
    console.log("[Tabbar] mounted");
    tabbarId = this.el.id;

    var initialTabId = this.el.dataset.initialTab
      ? "tab_" + this.el.dataset.initialTab
      : undefined;

    var savedTabId = this.loadActiveTab();
    var firstTabId = this.getFirstTab();

    // TODO: Fix optional chaining using Webpack >= 5.0.0
    var nextTabId = initialTabId
      ? initialTabId
      : savedTabId
      ? savedTabId
      : firstTabId;
    this.show(nextTabId, true);
  },

  updated() {
    console.log("[Tabbar] updated");
    var savedTabId = this.loadActiveTab();
    this.show(savedTabId, false);
  },

  getActiveTabKey() {
    return "tabbar://" + tabbarId + "/active_tab";
  },

  loadActiveTab() {
    const tabKey = this.getActiveTabKey();
    const activeTab = window.localStorage.getItem(tabKey);
    if (typeof activeTab === "string") {
      return activeTab;
    }
    return undefined;
  },

  saveActiveTab(tabId) {
    console.info("[Tabbar] saveActiveTab ", tabId);
    window.localStorage.setItem(this.getActiveTabKey(), tabId);
  },

  getTabs() {
    return document.querySelectorAll('[id^="tab_"]');
  },

  getFirstTab() {
    var tabs = this.getTabs();
    console.log("tabs", tabs);
    if (tabs == undefined) {
      return undefined;
    } else {
      return tabs[0].id;
    }
  },

  show(nextTabId, scrollToTop) {
    console.log("[Tabbar] nextTabId", nextTabId);
    if (nextTabId == undefined) {
      return;
    }

    this.saveActiveTab(nextTabId);
    var tabs = Array.from(document.querySelectorAll('[id^="tab_"]'));

    // Skip unknown tab
    if (!tabs.some((tab) => tab.id === nextTabId)) {
      console.warn("[Tabbar] Skip unknown tab", nextTabId);
      return;
    }

    // Show active tab
    tabs.forEach((tab) => {
      var isVisible = tab.id === nextTabId;
      setVisible(tab, isVisible);
      if (isVisible) {
        tab.dispatchEvent(new Event("tab-activated", { bubbles: true }));
      }
    });

    // Activate tabbar item for active tab
    var tabbar_items = Array.from(
      document.getElementsByClassName("tabbar-item")
    );
    tabbar_items.forEach((tabbar_item) => {
      var tab_id = "tab_" + tabbar_item.dataset.tabId;
      updateTabbarItem(tabbar_item, tab_id === nextTabId);
    });

    // Show footer item for active tab
    var tabbar_footer_items = Array.from(
      document.getElementsByClassName("tabbar-footer-item")
    );
    tabbar_footer_items.forEach((tabbar_footer_item) => {
      var tab_id = "tab_" + tabbar_footer_item.dataset.tabId;
      var isVisible = tab_id === nextTabId;
      setVisible(tabbar_footer_item, isVisible);
    });

    if (scrollToTop) {
      window.scrollTo(0, 0);
    }
  },
};

export const TabbarItem = {
  mounted() {
    this.el.addEventListener("click", (event) => {
      this.tabbar = document.getElementById("tabbar");
      Tabbar.show("tab_" + this.el.dataset.tabId, true);
    });
  },
};

export const TabbarFooterItem = {
  mounted() {
    this.el.addEventListener("click", (event) => {
      this.tabbar = document.getElementById("tabbar");
      Tabbar.show("tab_" + this.el.dataset.targetTabId, true);
    });
  },
};

function setVisible(element, isVisible) {
  element.classList[isVisible ? "remove" : "add"]("hidden");
}

function updateTabbarItem(tabbar_item, activate) {
  var hideWhenIdle =
    Array.from(tabbar_item.classList).filter((clazz) => {
      return clazz === "hide-when-idle";
    }).length > 0;

  if (hideWhenIdle) {
    setVisible(tabbar_item, activate);
  }

  var icon = tabbar_item.getElementsByClassName("icon")[0];
  var title = tabbar_item.getElementsByClassName("title")[0];

  updateElement(tabbar_item, activate);
  if (icon) {
    updateElement(icon, activate);
  }
  updateElement(title, activate);
}

function updateElement(element, activate) {
  if (!element) {
    return console.warn("Unknown element");
  }

  var idle_classes = customClasses(element, "idle");
  var active_classes = customClasses(element, "active");

  if (activate) {
    updateClassList(element, idle_classes, "remove");
    updateClassList(element, active_classes, "add");
  } else {
    updateClassList(element, active_classes, "remove");
    updateClassList(element, idle_classes, "add");
  }
}

function customClasses(element, name) {
  return element.getAttribute(name + "-class").split(" ");
}

function updateClassList(element, classes, type) {
  classes.forEach((clazz) => {
    element.classList[type](clazz);
  });
}
