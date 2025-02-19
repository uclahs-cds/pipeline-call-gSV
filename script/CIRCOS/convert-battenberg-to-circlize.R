### convert.battenberg.to.circlize() ###############################################################

# This script converts the output of battenberg into a format suitable for the circlize R package.

# Authors: Raag Agrawal (2023-04-03), Selina Wu (2023-05-10)


### NOTES ##########################################################################################

# The input file is originally from the <SAMPLE>_subclones.tsv from the battenberg output directory.
# You should preprocess this file by filtering the results to either only include the trunk or the
# branch, and output both a total CN and subclonal/clobal_cna_status column.

# The clonal_cna_status column should consist of either 0, 1, or -1 (0 is neutral, 1 is gain, and -1 is loss).
# The subclonal_cna_status column should consist of either 0, 1, or -1 (0 is neutral, 1 is gain, and -1 is loss).
#
# the input should at minimum have 4 columns: chr, startpos, endpos, clonal_cna_status (or subclonal_cna_status)
# but can handle any number of columns as long as they are named correctly


### FUNCTIONS ######################################################################################
## Function: process.battenberg.output -------------------------------------------------------------
# Input:
    # input.file (.tsv file) - preprocessed Battenberg results file for either clonal or subclonal CNAs
    # cna.3.colors (character vector) - colors for copy number gains/loss/neutral
# Output:
    # output.df (dataframe) - dataframe of further processed Battenberg clona/subclonal CNs

process.battenberg.output <- function(input.file, cna.3.colors) {
    # Read the TSV file
    battenberg.output <- read.table(
        file = input.file,
        header = TRUE,
        sep = '\t',
        stringsAsFactors = FALSE
        );

    # Filter the data frame to exclude rows with NA values in the 'V3' (endpos) and 'V2' (startpos) columns
    battenberg.filtered <- battenberg.output[!is.na(battenberg.output$endpos) & !is.na(battenberg.output$startpos), ];

    # Calculate the clonality.cna.status column
    battenberg.filtered$clonal.cna.status <- battenberg.filtered$clonal_cna_status;
    # if the input.file contains the word 'subclonal' then run this
        if (grepl('subclonal', input.file)) {
                battenberg.filtered$clonal.cna.status <- battenberg.filtered$subclonal_cna_status;
                }
        # Select the required columns and rename them
        output.df <- data.frame(
            chr = battenberg.filtered$chr,
            start = battenberg.filtered$startpos,
            end = battenberg.filtered$endpos,
            clonality.cna.status = battenberg.filtered$clonal.cna.status
            );
    # add color column that will be used to color the segments, takes user input of vector of colors of length 3
    output.df$col <- ifelse(
        output.df$clonality.cna.status == 0,
        cna.3.colors['neutral'],
        ifelse(
            output.df$clonality.cna.status == 1,
            cna.3.colors['gain'],
            cna.3.colors['loss']
            )
        );

    return(output.df);
    }

### FIN ############################################################################################
