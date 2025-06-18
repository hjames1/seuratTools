#' @title 在Seurat小提琴图上添加"一对合并组"比较的显著性
#'
#' @description
#' 对图中的每一个组，此函数会将其与所有其他组的合并体进行比较，
#' 并在每个小提琴图的上方直接标注p值或其显著性水平。
#'
#' @param seurat_obj 一个Seurat对象。
#' @param feature 要绘制的特征（例如，一个基因名）。
#' @param group.by 用于分组的metadata列名。
#' @param test.method 统计检验方法，"t.test" 或 "wilcox.test"。
#' @param p.adjust.method p值校正方法。如果为NULL（默认值），则不进行校正。可选值见 `stats::p.adjust`，常用 "fdr"。
#' @param label.type 标签显示类型。必须是 "signif" (显示显著性星号，默认) 或 "p.value" (显示数值)之一。
#' @param ... 其他所有要传递给 `Seurat::VlnPlot` 的参数。
#'
#' @return 返回一个带有统计检验注释的 ggplot 对象。
#'
#' @import Seurat
#' @import ggplot2
#' @importFrom rstatix t_test wilcox_test add_significance
#' @importFrom rlang as_name sym
#' @importFrom dplyr group_by summarise
#' @importFrom purrr map_dfr
#' @importFrom stats p.adjust
#' @importFrom scales pvalue
#'
#' @export
VlnPlot_pooled_test <- function(seurat_obj, feature, group.by, test.method = "wilcox.test", p.adjust.method = NULL, label.type = "signif", ...) {

  # 1. 创建基础图并提取数据
  p <- VlnPlot(seurat_obj, features = feature, group.by = group.by, ...)
  plot_data <- p$data
  group_col <- rlang::as_name(p$mapping$x)
  expr_col <- rlang::as_name(p$mapping$y)
  groups <- unique(plot_data[[group_col]])

  # 2. 循环遍历每个组，执行 "One vs Pooled Rest" 检验
  pooled_results <- purrr::map_dfr(groups, function(current_group) {
    temp_data <- plot_data
    temp_data$comparison_group <- ifelse(temp_data[[group_col]] == current_group, "Group1", "Rest")

    if (test.method == "t.test") {
      stat_res <- rstatix::t_test(data = temp_data, formula = as.formula(paste(expr_col, "~ comparison_group")))
    } else {
      stat_res <- rstatix::wilcox_test(data = temp_data, formula = as.formula(paste(expr_col, "~ comparison_group")))
    }
    data.frame(group = current_group, p = stat_res$p)
  })

  # --- 核心修改逻辑 ---
  # 3. 根据参数，决定是进行p值校正还是直接使用原始p值
  if (!is.null(p.adjust.method)) {
    # 场景A: 进行P值校正
    pooled_results$p.adj <- stats::p.adjust(pooled_results$p, method = p.adjust.method)
    pooled_results <- rstatix::add_significance(pooled_results, p.col = "p.adj", output.col = "p.adj.signif")

    # **修改点**: 使用 if/else if 明确判断 label.type
    if (label.type == "p.value") {
      pooled_results$plot_label <- scales::pvalue(pooled_results$p.adj, accuracy = 0.001, add_p = TRUE)
    } else if (label.type == "signif") {
      pooled_results$plot_label <- pooled_results$p.adj.signif
    } else {
      stop("无效的 label.type 参数: '", label.type, "'. 请选择 'signif' 或 'p.value'。")
    }

  } else {
    # 场景B: 不进行P值校正，使用原始p值
    pooled_results <- rstatix::add_significance(pooled_results, p.col = "p", output.col = "p.signif")

    # **修改点**: 使用 if/else if 明确判断 label.type
    if (label.type == "p.value") {
      pooled_results$plot_label <- scales::pvalue(pooled_results$p, accuracy = 0.001, add_p = TRUE)
    } else if (label.type == "signif") {
      pooled_results$plot_label <- pooled_results$p.signif
    } else {
      stop("无效的 label.type 参数: '", label.type, "'. 请选择 'signif' 或 'p.value'。")
    }
  }

  # 4. 计算每个标记的Y轴位置
  label_positions <- plot_data |>
    dplyr::group_by(!!rlang::sym(group_col)) |>
    dplyr::summarise(y.position = max(!!rlang::sym(expr_col), na.rm = TRUE))

  # 5. 合并统计结果和位置信息
  names(pooled_results)[names(pooled_results) == "group"] <- group_col
  final_labels <- merge(pooled_results, label_positions, by = group_col)

  # 6. 使用 geom_text 将最终标签添加到图中
  p_final <- p + ggplot2::geom_text(
    data = final_labels,
    aes(x = .data[[group_col]], y = y.position, label = plot_label),
    vjust = -0.5,
    fontface = "bold",
    size = 4
  ) +
    ggplot2::coord_cartesian(ylim = c(NA, max(final_labels$y.position) * 1.15), clip = "off")

  return(p_final)
}
