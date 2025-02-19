### setup-circos.r #################################################################################

# This script contains functions to initiate circos plotting.

# Authors: Raag Agrawal (2023-04-03), Selina Wu (2023-05-09)


### FUNCTIONS ######################################################################################
## Function: get.InsInvBnd.df ----------------------------------------------------------------------
# Description: This function takes in a BED data frame with 'INV', 'BND', and 'INS' SV types and
    # returns a list containing two modified BED data frames, insinvbnd.bed1 and insinvbnd.bed2,
    # using the 'chr.start', 'start', 'chr.end', and 'end' columns from the input dataframe.
# Input: sample.sv.df (dataframe) - dataframe of SVs processed from Delly/Manta VCF output
# Output:
    # ins.inv.bnd.bed1 (dataframe) - dataframe of SVs with starting chr and position
    # ins.inv.bnd.bed2 (dataframe) - dataframe of SVs with ending chr and position
    # insinvbnd.col (character vector) - list of colors for SVs
    # insinvbnd.lwd (num vector) - list of line widths for SVs
    # insinvbnd.lty (num vector) -  list of line types for SVs

get.InsInvBnd.df <- function(sample.sv.df) {
    # Filter the input dataframe to include only 'INV', 'TRA', 'BND', and 'INS' SV types
    ins.inv.bnd.df <- sample.sv.df[
        sample.sv.df$type == 'INV' |
        sample.sv.df$type == 'INS' |
        sample.sv.df$type == 'TRA' |
        sample.sv.df$type == 'BND', ];

    # If there are no entries with the specified SV types, return an empty list
    if (nrow(ins.inv.bnd.df) == 0) {
        return(list(ins.inv.bnd.df));
        }

    # Create ins.inv.bnd.bed1 and ins.inv.bnd.bed2 dataframes using the 'chr.start', 'start', 'chr.end', and 'end' columns
    ins.inv.bnd.bed1 <- ins.inv.bnd.df[, c('chr.start', 'start')];
    ins.inv.bnd.bed2 <- ins.inv.bnd.df[, c('chr.end', 'end')];

    # Rename the columns and set the 'end' column equal to the 'start' column for ins.inv.bnd.bed1 and ins.inv.bnd.bed2
    colnames(ins.inv.bnd.bed1) <- c('chr', 'start');
    ins.inv.bnd.bed1$end <- ins.inv.bnd.bed1$start;
    colnames(ins.inv.bnd.bed2) <- c('chr', 'start');
    ins.inv.bnd.bed2$end <- ins.inv.bnd.bed2$start;

    # Generate insinvbnd.col, insinvbnd.lwd, and insinvbnd.lty for the selected SV types
    ins.inv.bnd.col <- sv.colors[ins.inv.bnd.df$type];
    ins.inv.bnd.lwd <- rep(2, nrow(ins.inv.bnd.df));
    ins.inv.bnd.lty <- rep(1, nrow(ins.inv.bnd.df));

    return(
        list(
            ins.inv.bnd.bed1,
            ins.inv.bnd.bed2,
            ins.inv.bnd.col,
            ins.inv.bnd.lwd,
            ins.inv.bnd.lty
            )
        );
    }


### CIRCOS FUNCTIONS ###############################################################################
## Function: CIRCLIZE.DUPDEL -----------------------------------------------------------------------
# Description: This function plots the duplication and deletion SVs on the circos plot
# Input: cnas.to.plot (dataframe) - dataframe of CNAs that have been preprocessed
CIRCLIZE.DUPDEL <- function(cnas.to.plot) {
    bedlist2 <- cnas.to.plot;

    circos.genomicTrackPlotRegion(
        bedlist2,
        ylim = c(0.1, 0.9),
        track.height = 0.15,
        panel.fun = function(region, value, ...) {
            i <- getI(...);
            circos.genomicRect(
                region,
                value,
                col = value$col,
                ytop = 1,
                ybottom = 0,
                border = NA
                );
            }
        );
    }

## Function: CIRCLIZE.INSINVBND --------------------------------------------------------------------
# Description: Plots the inversion, insertion, and interchromosomal SVs on the circos plot
# Input: insinvbnd.list (list of dataframes) - list of dataframe outputs from get.InsInvBnd.df

CIRCLIZE.INSINVBND <- function(insinvbnd.list) {
    insinvbnd.bed1 <- insinvbnd.list[[1]];
    insinvbnd.bed2 <- insinvbnd.list[[2]];
    insinvbnd.col <- insinvbnd.list[[3]];
    insinvbnd.lwd <- insinvbnd.list[[4]];
    insinvbnd.lty <- insinvbnd.list[[5]];

    # Convert start and end positions to numerics
    insinvbnd.bed1$start <- as.numeric(insinvbnd.bed1$start);
    insinvbnd.bed1$end <- as.numeric(insinvbnd.bed1$end);
    insinvbnd.bed2$start <- as.numeric(insinvbnd.bed2$start);
    insinvbnd.bed2$end <- as.numeric(insinvbnd.bed2$end);

    circos.genomicLink(
        region1 = insinvbnd.bed1,
        region2 = insinvbnd.bed2,
        lwd = 1,
        col = insinvbnd.col,
        border = NA
        );
    }

## Function: CIRCLIZE.SETUP ------------------------------------------------------------------------
# Description: Initializes the circos plot.
    # The commented out line can be uncommented to create an ideogram for each chromosome
# Input: species (character) - specify the specifies

CIRCLIZE.SETUP <- function(species = 'hg38') {
    circos.par('start.degree' = 90);
    circos.par('gap.degree' = rep(c(2), 24));
    circos.initializeWithIdeogram(plotType = NULL, species = species);
    # circos.initializeWithIdeogram(
    #     species = 'hg38',
    #     chromosome.index = paste0('chr', c(1:22, 'X', 'Y'))
    #     );
    }

## Function: CIRCLIZE.CHROMOSOME.LAYOUT ------------------------------------------------------------
# Description: Plots the chromosome layout on the circos plot

CIRCLIZE.CHROMOSOME.LAYOUT <- function() {
    circos.track(
        panel.fun = function(x, y) {
            chrchr <- CELL_META$sector.index
            chr <- gsub('chr', '', chrchr)
            xlim <- CELL_META$xlim
            ylim <- CELL_META$ylim
            circos.rect(
                xlim[1],
                0,
                xlim[2],
                1,
                col = force.colour.scheme(chr, 'chromosome')
                );
            circos.text(
                mean(xlim),
                1.2,
                labels = chr,
                cex = 1.4,
                adj = c(0.5, 0),
                col = 'black',
                facing = 'inside',
                niceFacing = TRUE
                );
            },
        ylim = c(0, 1),
        track.height = 0.05,
        bg.border = NA
        )
    }

### FIN ############################################################################################
