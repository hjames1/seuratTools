
<!-- README.md is generated from README.Rmd. Please edit that file -->

# seuratTools

<!-- badges: start -->

<!-- badges: end -->

The goal of seuratTools is to …

## Installation

You can install the development version of seuratTools from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hjames1/seuratTools")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
# 载入你的包和数据
library(Seurat)
#> Loading required package: SeuratObject
#> Loading required package: sp
#> 
#> Attaching package: 'SeuratObject'
#> The following objects are masked from 'package:base':
#> 
#>     intersect, t
```

``` r
library(seuratTools)
data(pbmc1k) 
pbmc1k <- SCTransform(pbmc1k, verbose = FALSE)
#> Warning: The `slot` argument of `GetAssayData()` is deprecated as of SeuratObject 5.0.0.
#> ℹ Please use the `layer` argument instead.
#> ℹ The deprecated feature was likely used in the Seurat package.
#>   Please report the issue at <https://github.com/satijalab/seurat/issues>.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
#> Warning: The `slot` argument of `SetAssayData()` is deprecated as of SeuratObject 5.0.0.
#> ℹ Please use the `layer` argument instead.
#> ℹ The deprecated feature was likely used in the Seurat package.
#>   Please report the issue at <https://github.com/satijalab/seurat/issues>.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

``` r
# 场景1 (默认行为): 校正P值，显示星号
VlnPlot_pooled_test(pbmc1k, "MS4A1", "seurat_annotations", p.adjust.method = "fdr", label.type = "signif")
#> Warning: The `slot` argument of `FetchData()` is deprecated as of SeuratObject 5.0.0.
#> ℹ Please use the `layer` argument instead.
#> ℹ The deprecated feature was likely used in the Seurat package.
#>   Please report the issue at <https://github.com/satijalab/seurat/issues>.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
#> Warning: `PackageCheck()` was deprecated in SeuratObject 5.0.0.
#> ℹ Please use `rlang::check_installed()` instead.
#> ℹ The deprecated feature was likely used in the Seurat package.
#>   Please report the issue at <https://github.com/satijalab/seurat/issues>.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

# 场景2: 校正P值，显示数值
VlnPlot_pooled_test(pbmc1k, "MS4A1", "seurat_annotations", p.adjust.method = "fdr", label.type = "p.value")
```

<img src="man/figures/README-example-2.png" width="100%" />

``` r

# 场景3: 不校正，直接用原始P值显示星号
VlnPlot_pooled_test(pbmc1k, "MS4A1", "seurat_annotations", p.adjust.method = NULL, label.type = "signif")
```

<img src="man/figures/README-example-3.png" width="100%" />

``` r

# 场景4: 不校正，直接用原始P值显示数值
VlnPlot_pooled_test(pbmc1k, "MS4A1", "seurat_annotations", p.adjust.method = NULL, label.type = "p.value")
```

<img src="man/figures/README-example-4.png" width="100%" />

``` r

# 加载IFNB数据
data("ifnb1k")
ifnb1k <- SCTransform(ifnb1k, verbose = FALSE)

# 场景1: 默认行为（BH校正，显示星号）
PlotCompareExpression(
  seurat_obj = ifnb1k,
  feature = "CXCR4",
  group.by = "seurat_annotations",
  p.adjust.method = "BH",
  split.by = "stim"
)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

``` r

# 场景2: BH校正，显示P值数值
PlotCompareExpression(
  seurat_obj = ifnb1k,
  feature = "CXCR4",
  group.by = "seurat_annotations",
  split.by = "stim",
  p.adjust.method = "BH",
  label.type = "p.value"
  
)
```

<img src="man/figures/README-unnamed-chunk-2-2.png" width="100%" />

``` r

# 场景3: 不进行校正，直接显示原始P值的星号
PlotCompareExpression(
  seurat_obj = ifnb1k,
  feature = "CXCR4",
  group.by = "seurat_annotations",
  split.by = "stim",
  p.adjust.method = NULL # 传入 NULL 来跳过校正
)
```

<img src="man/figures/README-unnamed-chunk-2-3.png" width="100%" />

``` r

# 场景4: 不进行校正，直接显示原始P值的数值
PlotCompareExpression(
  seurat_obj = ifnb1k,
  feature = "CXCR4",
  group.by = "seurat_annotations",
  split.by = "stim",
  label.type = "p.value",
  p.adjust.method = NULL # 传入 NULL 来跳过校正
)
```

<img src="man/figures/README-unnamed-chunk-2-4.png" width="100%" />
