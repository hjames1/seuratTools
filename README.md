
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
library(seuratTools)
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
library(SeuratData)
#> ── Installed datasets ──────────────────────────────── SeuratData v0.2.2.9002 ──
#> ✔ pbmc3k       3.1.4                    ✔ pbmcMultiome 0.1.4
#> ────────────────────────────────────── Key ─────────────────────────────────────
#> ✔ Dataset loaded successfully
#> ❯ Dataset built with a newer version of Seurat than installed
#> ❓ Unknown version of Seurat installed
```

``` r
InstallData("pbmc3k")
#> Warning: The following packages are already installed and will not be
#> reinstalled: pbmc3k
```

``` r
data("pbmc3k.final")
pbmc <- pbmc3k.final
pbmc <- UpdateSeuratObject(pbmc)
#> Validating object structure
#> Updating object slots
#> Ensuring keys are in the proper structure
#> Updating matrix keys for DimReduc 'pca'
#> Updating matrix keys for DimReduc 'umap'
#> Warning: Assay RNA changing from Assay to Assay
#> Warning: Graph RNA_nn changing from Graph to Graph
#> Warning: Graph RNA_snn changing from Graph to Graph
#> Warning: DimReduc pca changing from DimReduc to DimReduc
#> Warning: DimReduc umap changing from DimReduc to DimReduc
#> Ensuring keys are in the proper structure
#> Ensuring feature names don't have underscores or pipes
#> Updating slots in RNA
#> Updating slots in RNA_nn
#> Setting default assay of RNA_nn to RNA
#> Updating slots in RNA_snn
#> Setting default assay of RNA_snn to RNA
#> Updating slots in pca
#> Updating slots in umap
#> Setting umap DimReduc to global
#> Setting assay used for NormalizeData.RNA to RNA
#> Setting assay used for FindVariableFeatures.RNA to RNA
#> Setting assay used for ScaleData.RNA to RNA
#> Setting assay used for RunPCA.RNA to RNA
#> Setting assay used for JackStraw.RNA.pca to RNA
#> No assay information could be found for ScoreJackStraw
#> Warning: Adding a command log without an assay associated with it
#> Setting assay used for FindNeighbors.RNA.pca to RNA
#> No assay information could be found for FindClusters
#> Warning: Adding a command log without an assay associated with it
#> Setting assay used for RunUMAP.RNA.pca to RNA
#> Validating object structure for Assay 'RNA'
#> Validating object structure for Graph 'RNA_nn'
#> Validating object structure for Graph 'RNA_snn'
#> Validating object structure for DimReduc 'pca'
#> Validating object structure for DimReduc 'umap'
#> Object representation is consistent with the most current Seurat version
```

``` r
VlnPlot_pooled_test(
  seurat_obj = pbmc,
  feature = "MS4A1",
  group.by = "seurat_annotations",
  test.method = "wilcox.test",
  pt.size = 0.1
)
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
