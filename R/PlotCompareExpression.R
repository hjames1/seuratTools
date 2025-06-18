#' @title 比较不同条件下各分组的基因表达并进行可视化
#'
#' @description
#' 此函数用于可视化在两个不同条件下（如对照组 vs 刺激组），
#' 多个细胞类型中某个基因的表达差异。它会自动过滤掉细胞数过少的组，
#' 对每组进行Wilcoxon或t检验，对p值进行多重检验校正，并用分面箱线图展示结果。
#'
#' @param seurat_obj 一个Seurat对象。
#' @param feature 要绘制的特征（例如，一个基因名）。
#' @param group.by 用于分面的主要分组变量（例如 "seurat_annotations", 细胞类型）。
#' @param split.by 用于在每个分面内进行比较的分组变量（例如 "stim", 处理条件），此变量应只包含两个水平。
#' @param min.cells 整数，一个分组中被保留的最小细胞数。少于此数目的分组将被过滤掉。默认为 50。
#' @param test.method 统计检验方法，"wilcox.test" (默认) 或 "t.test"。
#' @param p.adjust.method p值校正方法。如果为NULL，则不进行校正。常用 "BH" (或 "fdr")。默认为 "BH"。
#' @param label.type 标签显示类型。必须是 "signif" (显示显著性星号，默认) 或 "p.value" (显示数值)之一。
#' @param colors 一个包含两种颜色的向量，用于指定 `split.by` 变量的颜色。默认为 c("blue", "red")。
#' @param ... 其他要传递给 `ggpubr::ggboxplot` 的参数。
#'
#' @return 返回一个 ggplot 对象。
#'
#' @import Seurat
#' @import ggplot2
#' @import ggpubr
#' @importFrom rstatix wilcox_test t_test adjust_pvalue add_significance add_y_position p_format
#' @importFrom dplyr filter group_by
#' @importFrom rlang sym
#'
#' @export
PlotCompareExpression <- function(seurat_obj,
                                  feature,
                                  group.by,
                                  split.by,
                                  min.cells = 50,
                                  test.method = "wilcox.test",
                                  p.adjust.method = "BH",
                                  label.type = "signif",
                                  colors = c("blue", "red"),
                                  ...) {

  # 1. 过滤掉细胞数过少的分组
  cell_counts <- table(seurat_obj@meta.data[[group.by]])
  groups_to_keep <- names(cell_counts[cell_counts > min.cells])
  if (length(groups_to_keep) == 0) {
    stop("所有分组的细胞数都少于指定的 min.cells (", min.cells, ")。")
  }
  seurat_filtered <- subset(seurat_obj, !!rlang::sym(group.by) %in% groups_to_keep)

  # 2. 提取绘图所需数据
  plot_df <- FetchData(seurat_filtered, vars = c(feature, group.by, split.by))
  # 为了后续代码的稳定性，重命名列
  colnames(plot_df) <- c("expression", "group", "split")

  # 3. 按分组进行统计检验
  stat_test_pipe <- plot_df %>%
    dplyr::group_by(group)

  if (test.method == "wilcox.test") {
    stat_test_pipe <- stat_test_pipe %>% rstatix::wilcox_test(expression ~ split)
  } else if (test.method == "t.test") {
    stat_test_pipe <- stat_test_pipe %>% rstatix::t_test(expression ~ split)
  } else {
    stop("无效的 test.method。请选择 'wilcox.test' 或 't.test'。")
  }

  # 4. 根据参数决定P值校正和标签类型
  if (!is.null(p.adjust.method)) {
    # 场景A: 进行P值校正
    stat_test <- stat_test_pipe %>% rstatix::adjust_pvalue(method = p.adjust.method)
    stat_test <- stat_test %>% rstatix::add_significance(p.col = "p.adj", output.col = "p.adj.signif")

    if (label.type == "p.value") {
      stat_test$plot_label <- rstatix::p_format(stat_test$p.adj, accuracy = 0.001, leading.zero = FALSE)
    } else if (label.type == "signif") {
      stat_test$plot_label <- stat_test$p.adj.signif
    } else {
      stop("无效的 label.type 参数: '", label.type, "'. 请选择 'signif' 或 'p.value'。")
    }
  } else {
    # 场景B: 不校正，使用原始p值
    stat_test <- stat_test_pipe %>% rstatix::add_significance(p.col = "p", output.col = "p.signif")

    if (label.type == "p.value") {
      stat_test$plot_label <- rstatix::p_format(stat_test$p, accuracy = 0.001, leading.zero = FALSE)
    } else if (label.type == "signif") {
      stat_test$plot_label <- stat_test$p.signif
    } else {
      stop("无效的 label.type 参数: '", label.type, "'. 请选择 'signif' 或 'p.value'。")
    }
  }

  # 5. 计算标签的Y轴位置
  stat_test <- stat_test %>% rstatix::add_y_position(data = plot_df, scales = "free")

  # 6. 创建分面箱线图并添加P值标签
  p <- ggpubr::ggboxplot(
    plot_df, x = "split", y = "expression",
    color = "split", palette = colors,
    add = "jitter",
    ...
  )

  p_final <- ggpubr::facet(p, facet.by = "group",
                           nrow = 1,
                           panel.labs.background = list(color = NA, fill = NA)) +
    ggpubr::stat_pvalue_manual(stat_test, label = "plot_label", y.position = "y.position") +
    ggplot2::labs(x = NULL, y = paste(feature, "Expression")) +
    ggplot2::theme(strip.text.x = element_text(size = 10))

  return(p_final)
}
