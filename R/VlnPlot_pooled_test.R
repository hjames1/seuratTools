#' @title 在Seurat小提琴图上添加"一对合并组"比较的显著性
#'
#' @description
#' 对图中的每一个组，此函数会将其与所有其他组的合并体进行比较，
#' 并在每个小提琴图的上方直接标注FDR校正后的p值显著性。
#'
#' @param seurat_obj 一个Seurat对象。
#' @param feature 要绘制的特征（例如，一个基因名）。
#' @param group.by 用于分组的metadata列名。
#' @param test.method 统计检验方法，"t.test" 或 "wilcox.test"。
#' @param p.adjust.method p值校正方法，默认为 "fdr"。
#' @param ... 其他所有要传递给 `Seurat::VlnPlot` 的参数。
#'
#' @return 返回一个带有统计检验注释的 ggplot 对象。
#'
#' @import Seurat
#' @import ggplot2
#' @importFrom rstatix t_test wilcox_test adjust_pvalue add_significance
#' @importFrom rlang as_name sym
#' @importFrom dplyr group_by summarise n
#' @importFrom purrr map_dfr
#'
#' @export
VlnPlot_pooled_test <- function(seurat_obj, feature, group.by, test.method = "wilcox.test", p.adjust.method = "fdr", ...) {

  # 1. 创建基础图并提取数据
  p <- VlnPlot(seurat_obj, features = feature, group.by = group.by, ...)
  plot_data <- p$data
  group_col <- rlang::as_name(p$mapping$x)
  expr_col <- rlang::as_name(p$mapping$y)

  # 获取所有唯一的组别
  groups <- unique(plot_data[[group_col]])

  # 2. 循环遍历每个组，执行 "One vs Pooled Rest" 检验
  pooled_results <- purrr::map_dfr(groups, function(current_group) {

    # 创建临时数据和 "One vs Rest" 分组
    temp_data <- plot_data
    temp_data$comparison_group <- ifelse(temp_data[[group_col]] == current_group, "Group1", "Rest")

    # 执行双组检验
    if (test.method == "t.test") {
      stat_res <- rstatix::t_test(data = temp_data, formula = as.formula(paste(expr_col, "~ comparison_group")))
    } else {
      stat_res <- rstatix::wilcox_test(data = temp_data, formula = as.formula(paste(expr_col, "~ comparison_group")))
    }

    # 返回包含组名和p值的结果
    data.frame(group = current_group, p = stat_res$p)
  })

  # 3. 对所有p值进行校正，并添加显著性标记
  pooled_results$p.adj <- stats::p.adjust(pooled_results$p, method = p.adjust.method)
  pooled_results <- rstatix::add_significance(pooled_results, p.col = "p.adj", output.col = "p.adj.signif")

  # 4. 计算每个标记的Y轴位置（在小提琴图顶端）
  label_positions <- plot_data |>
    dplyr::group_by(!!rlang::sym(group_col)) |>
    dplyr::summarise(y.position = max(!!rlang::sym(expr_col), na.rm = TRUE))

  # 5. 合并统计结果和位置信息
  # 注意：列名需要匹配，我们将 pooled_results 的 'group' 改为与 group_col 相同的名字
  names(pooled_results)[names(pooled_results) == "group"] <- group_col
  final_labels <- merge(pooled_results, label_positions, by = group_col)

  # 6. 使用 geom_text 将显著性标记添加到图中
  p_final <- p + ggplot2::geom_text(
    data = final_labels,
    aes(x = .data[[group_col]], y = y.position, label = p.adj.signif),
    vjust = -0.5, # 垂直方向上轻微上移
    fontface = "bold",
    size = 5
  ) +
    ggplot2::coord_cartesian(ylim = c(NA, max(final_labels$y.position) * 1.15), clip = "off") # 确保Y轴有足够空间

  return(p_final)
}
