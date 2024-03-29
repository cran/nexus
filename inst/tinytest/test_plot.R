if (at_home()) {
  using("tinysnapshot")
  options(tinysnapshot_device = "svglite")
  options(tinysnapshot_height = 7) # inches
  options(tinysnapshot_width = 7)
  options(tinysnapshot_tol = 200) # pixels
  options(tinysnapshot_os = "Linux")

  data("hongite")
  coda <- as_composition(hongite)

  # Plot =======================================================================
  plot_pairs <- function() plot(coda, order = NULL)
  expect_snapshot_plot(plot_pairs, "plot_pairs")

  # Histogram ==================================================================
  plot_hist <- function() hist(coda, ncol = 3)
  expect_snapshot_plot(plot_hist, "plot_hist")

  # Barplot ====================================================================
  plot_barplot <- function() barplot(coda, order = NULL)
  expect_snapshot_plot(plot_barplot, "plot_barplot")

  plot_barplot_order <- function() barplot(coda, order = 2)
  expect_snapshot_plot(plot_barplot_order, "plot_barplot_order")

  set_groups(coda) <- rep(1:5, 5)
  plot_barplot_group <- function() barplot(coda, order = 2)
  expect_snapshot_plot(plot_barplot_group, "plot_barplot_group")

  plot_barplot_vertical <- function() barplot(coda, order = NULL, horiz = FALSE)
  expect_snapshot_plot(plot_barplot_vertical, "plot_barplot_vertical")

  # Scatterplot ================================================================
  # clr <- transform_clr(coda)
  #
  # plot_ratio <- function() plot(clr, order = NULL, groups = NULL)
  # expect_snapshot_plot(plot_ratio, "plot_ratio")
  #
  # plot_ratio_group <- function() plot(clr, order = NULL)
  # expect_snapshot_plot(plot_ratio_group, "plot_ratio_group")
}
