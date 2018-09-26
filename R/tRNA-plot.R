#' @include tRNA.R
NULL

#' @name plottRNAFeatures
#' 
#' @title Graphical summary of tRNA features
#' 
#' @description 
#' 
#' @return a ggplot2
#' 
#' @export
#' 
#' @examples 
#' \donttest{
#' }

TRNA_PLOT_LABELS <- list(gc = "GC content [%]",
                         width = "gene width [bp]",
                         length = "Length [nt]",
                         score = "Score",
                         cca = "genomically encoded 3'-CCA ends [%]",
                         
                         features_all_valid = "all tRNA structures found [%]",
                         features_Dstem_found = "with D loop [%]",
                         features_Tstem_found = "with T loop [%]",
                         
                         acceptorStem_length = "Acceptor stem length [nt]",
                         Dprime5_length = "Length [nt]",
                         DStem_length = "D stem length [nt]",
                         Dloop_length = "D loop length [nt]",
                         Dprime3_length = "Length [nt]",
                         anticodonStem_length = "Anticodon stem length [nt]",
                         anticodonLoop_length = "Anticodon loop length [nt]",
                         variableLoop_length = "Variable loop length [nt]",
                         TStem_length = "T stem length [nt]",
                         Tloop_length = "T loop length [nt]",
                         discriminator_length = "Length [nt]",
                         
                         acceptorStem_unpaired = "Acceptor stem unpaired [%]",
                         DStem_unpaired = "D stem stem unpaired [%]",
                         anticodonStem_unpaired = "Anticodon stem unpaired [%]",
                         variableLoop_unpaired = "Variable loop unpaired [%]",
                         TStem_unpaired = "T stem unpaired [%]",
                         
                         acceptorStem_mismatches = "Acceptor stem mismatches [%]",
                         DStem_mismatches = "D stem mismatches [%]",
                         anticodonStem_mismatches = "Anticodon stem mismatches [%]",
                         variableLoop_mismatches = "Variable loop mismatches [%]",
                         TStem_mismatches = "T stem mismatches [%]",
                         
                         acceptorStem_bulges = "Acceptor stem bulges [%]",
                         DStem_bulges = "D stem bulges [%]",
                         anticodonStem_bulges = "Anticodon stem bulges [%]",
                         variableLoop_bulges = "Variable loop bulges [%]",
                         TStem_bulges = "T stem bulges [%]",
                         
                         tRNAscan_potential.pseudogene = "Potential pseudogenes [%]",
                         tRNAscan_intron = "Introns [%]",
                         tRNAscan_score = "tRNAscan-SE score",
                         tRNAscan_hmm.score = "HMM score",
                         tRNAscan_sec.str.score = "Secondary structure score",
                         tRNAscan_infernal = "Infernal score")

# allowed values NA, "percent", "yn"
TRNA_PLOT_DATATYPES <- list(gc = "percent",
                            width = NA,
                            length = NA,
                            score = NA,
                            cca = "yn",
                            
                            features_all_valid = "yn",
                            features_Dstem_found = "yn",
                            features_Tstem_found = "yn",
                            
                            acceptorStem_length = NA,
                            Dprime5_length = NA,
                            DStem_length = NA,
                            Dloop_length = NA,
                            Dprime3_length = NA,
                            anticodonStem_length = NA,
                            anticodonLoop_length = NA,
                            variableLoop_length = NA,
                            TStem_length = NA,
                            Tloop_length = NA,
                            discriminator_length = NA,
                            
                            acceptorStem_unpaired = "yn",
                            DStem_unpaired = "yn",
                            anticodonStem_unpaired = "yn",
                            variableLoop_unpaired = "yn",
                            TStem_unpaired = "yn",
                            
                            acceptorStem_mismatches = "yn",
                            DStem_mismatches = "yn",
                            anticodonStem_mismatches = "yn",
                            variableLoop_mismatches = "yn",
                            TStem_mismatches = "yn",
                            
                            acceptorStem_bulges = "yn",
                            DStem_bulges = "yn",
                            anticodonStem_bulges = "yn",
                            variableLoop_bulges = "yn",
                            TStem_bulges = "yn",
                            
                            tRNAscan_potential.pseudogene = "yn",
                            tRNAscan_intron = "yn",
                            tRNAscan_score = NA,
                            tRNAscan_hmm.score = NA,
                            tRNAscan_sec.str.score = NA,
                            tRNAscan_infernal = NA)

#' @rdname plottRNAFeatures
#' @export
setMethod(
  f = "gettRNAFeaturePlots",
  signature = signature(grl = "GRangesList"),
  definition = function(grl) {
    # Input check
    if(length(grl) == 0)
      stop("GRangesList of length == 0 provided.",
           call. = FALSE)
    names <- names(grl)
    if(any(duplicated(names))){
      stop("Duplicated names in GRangesList not supported.",
           call. = FALSE)
    }
    if(is.null(names)){
      stop("GrangesList elements are not named.",
           call. = FALSE)
    }
    # aggregate data
    data <- lapply(seq_len(length(grl)),
                   function(i){
                     mcoldata <- gettRNASummary(grl[[i]])
                     name <- names(grl[i])
                     coldata <- lapply(seq_len(ncol(mcoldata)),
                                       function(i){
                                         column <- mcoldata[,i]
                                         column <- column[!is.na(column)]
                                         if(length(column) == 0) return(NULL)
                                         data.frame(id = name,
                                                    value = column)
                                       })
                     names(coldata) <- colnames(mcoldata)
                     return(coldata)
                   })
    dataNames <- unique(unlist(lapply(data, names)))
    data <- lapply(dataNames,
                   function(name){
                     do.call(rbind, lapply(data, "[[", name))
                   })
    names(data) <- dataNames
    # plot data
    colour_palette <- .get_colour("palette")
    colour_yes <- .get_colour("yes")
    colour_no <- .get_colour("no")
    plots <- lapply(seq_len(length(data)),
                    function(i){
                      if(is.null(data[[i]])){
                        return(NULL)
                      }
                      .get_plot(df = data[i],
                                colour_palette = colour_palette,
                                colour_yes = colour_yes,
                                colour_no = colour_no)
                    })
    names(plots) <- dataNames
    plots <- plots[!vapply(plots, is.null, logical(1))]
    return(plots)
  }
)

# get a plot for one data type
.get_plot <- function(df,
                      colour_palette,
                      colour_yes,
                      colour_no){
  writtenNames <- TRNA_PLOT_LABELS
  dataType <- TRNA_PLOT_DATATYPES
  name <- names(df)
  if(length(dataType[[name]]) == 0){
    stop("Something went wrong.")
  }
  if(is.na(dataType[[name]])){
    min <- min(df[[name]]$value)
    max <- max(df[[name]]$value)
    plot <- ggplot2::ggplot(df[[name]],
                            ggplot2::aes_(x = ~id,
                                          y = ~value,
                                          colour = ~id)) +
      ggplot2::geom_violin(scale = "width") +
      ggplot2::geom_jitter(width = 0.2,
                           height = 0.2) +
      ggplot2::scale_x_discrete(name = "Organism") +
      ggplot2::scale_y_continuous(name = writtenNames[[name]]) +
      ggplot2::scale_colour_brewer(name = "Organism",
                                   palette = colour_palette) + 
      ggplot2::expand_limits(y = c(min - 1,
                                   max + 1))
  } 
  if(!is.na(dataType[[name]]) &&
     dataType[[name]] == "percent"){
    plot <- ggplot2::ggplot(df[[name]],
                            ggplot2::aes_(x = ~id,
                                          y = ~value,
                                          colour = ~id)) +
      ggplot2::geom_violin(scale = "width") +
      ggplot2::geom_jitter(width = 0.2) +
      ggplot2::scale_x_discrete(name = "Organism") +
      ggplot2::scale_y_continuous(name = writtenNames[[name]],
                                  breaks = c(0,0.25,0.5,0.75,1),
                                  labels = scales::percent,
                                  limits = c(0,1)) +
      ggplot2::scale_colour_brewer(name = "Organism",
                                   palette = colour_palette)
  }
  if(!is.na(dataType[[name]]) &&
     dataType[[name]] == "yn"){
    df[[name]][df[[name]]$value == 1,"colour"] <- colour_yes
    df[[name]][df[[name]]$value == 0,"colour"] <- colour_no
    df[[name]][df[[name]]$value == 1,"value"] <- "Yes"
    df[[name]][df[[name]]$value == 0,"value"] <- "No"
    plot <- ggplot2::ggplot(df[[name]],
                            ggplot2::aes_(x = ~id,
                                          y = ~((..count..)/sum(..count..)),
                                          fill = ~colour)) +
      ggplot2::geom_bar(position = "fill") +
      ggplot2::scale_x_discrete(name = "Organism") +
      ggplot2::scale_y_continuous(name = writtenNames[[name]],
                                  labels = scales::percent,
                                  limits = c(0,1)) +
      ggplot2::scale_fill_identity(name = "",
                                   guide = "legend",
                                   labels = c("Yes","No"))
  }
  return(plot)
}