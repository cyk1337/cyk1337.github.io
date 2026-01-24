$(document).ready(function () {
  // add toggle functionality to abstract, award, bibtex and tldr buttons
  $("a.abstract").click(function () {
    $(this).parent().parent().find(".abstract.hidden").toggleClass("open");
    $(this).parent().parent().find(".award.hidden.open").toggleClass("open");
    $(this).parent().parent().find(".bibtex.hidden.open").toggleClass("open");
    $(this).parent().parent().find(".tldr-content.hidden.open").toggleClass("open");
  });
  $("a.award").click(function () {
    $(this).parent().parent().find(".abstract.hidden.open").toggleClass("open");
    $(this).parent().parent().find(".award.hidden").toggleClass("open");
    $(this).parent().parent().find(".bibtex.hidden.open").toggleClass("open");
    $(this).parent().parent().find(".tldr-content.hidden.open").toggleClass("open");
  });
  $("a.bibtex").click(function () {
    $(this).parent().parent().find(".abstract.hidden.open").toggleClass("open");
    $(this).parent().parent().find(".award.hidden.open").toggleClass("open");
    $(this).parent().parent().find(".bibtex.hidden").toggleClass("open");
    $(this).parent().parent().find(".tldr-content.hidden.open").toggleClass("open");
  });

  // Handle TL;DR button clicks - the button has class "abstract" when entry.tldr exists
  // We need to distinguish between abstract and tldr clicks by checking text content
  $("a.abstract").each(function() {
    var buttonText = $(this).text().trim();
    if (buttonText.indexOf("TL;DR") !== -1 || buttonText === "TL;DR") {
      $(this).off('click'); // Remove the default abstract handler
      $(this).on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var $parent = $(this).parent().parent();
        $parent.find(".tldr-content.hidden").toggleClass("open");
        $parent.find(".abstract.hidden.open").toggleClass("open");
        $parent.find(".award.hidden.open").toggleClass("open");
        $parent.find(".bibtex.hidden.open").toggleClass("open");
        return false;
      });
    }
  });

  $("a").removeClass("waves-effect waves-light");

  // bootstrap-toc
  if ($("#toc-sidebar").length) {
    // remove related publications years from the TOC
    $(".publications h2").each(function () {
      $(this).attr("data-toc-skip", "");
    });
    var navSelector = "#toc-sidebar";
    var $myNav = $(navSelector);
    Toc.init($myNav);
    $("body").scrollspy({
      target: navSelector,
    });
  }

  // add css to jupyter notebooks
  const cssLink = document.createElement("link");
  cssLink.href = "../css/jupyter.css";
  cssLink.rel = "stylesheet";
  cssLink.type = "text/css";

  let jupyterTheme = determineComputedTheme();

  $(".jupyter-notebook-iframe-container iframe").each(function () {
    $(this).contents().find("head").append(cssLink);

    if (jupyterTheme == "dark") {
      $(this).bind("load", function () {
        $(this).contents().find("body").attr({
          "data-jp-theme-light": "false",
          "data-jp-theme-name": "JupyterLab Dark",
        });
      });
    }
  });

  // trigger popovers
  $('[data-toggle="popover"]').popover({
    trigger: "hover",
  });
});
