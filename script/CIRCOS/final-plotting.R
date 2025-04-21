### plot.final.R ###################################################################################

# This script takes all the functions and command line inputs and generates the final circos plot.

### PREAMBLE #######################################################################################
library(BoutrosLab.plotting.general);
library(argparse);
library(vcfR);
library(circlize);

### COMMAND LINE PARAMETERS ########################################################################
# Create an argument parser
parser <- ArgumentParser(description = 'A script that processes command-line arguments');

# Add arguments to the parser
parser$add_argument('--input.vcf', type = 'character', help = 'Path to the input ANNOTATED vcf', required = TRUE);
parser$add_argument('--output.dir', type = 'character', help = 'Output directory', required = TRUE);
parser$add_argument('--output.type', type = 'character', help = 'output format e.g. png, pdf', default = 'png');
parser$add_argument('--output.filename', type = 'character', help = 'output filename with extension', required = TRUE);
parser$add_argument('--sample.name', type = 'character', help = 'Sample name', required = TRUE);
parser$add_argument('--script.source', type = 'character', help = 'Path to directory containing helper scripts', required = TRUE);
parser$add_argument('--sv.caller', type = 'character', help = 'Either DELLY or Manta verbatim', default = 'DELLY');
parser$add_argument('--plot.title', type = 'logical', help = 'print a title? TRUE or FALSE', default = TRUE);

# Parse the command-line arguments
args <- parser$parse_args();

# Store the arguments in variables
input.vcf <- args$input.vcf;
output.dir <- args$output.dir;
sample.name <- args$sample.name;
output.filename <- args$output.filename;
sv.caller <- args$sv.caller;
cna.caller <- args$cna.caller;
output.type <- args$output.type;
plot.title <- args$plot.title;
script.source <- args$script.source;

# Print the values of the variables
cat('Input SV file:', input.vcf, '\n');
cat('Output directory:', output.dir, '\n');
cat('Output type:', output.type, '\n');
cat('Sample name:', sample.name, '\n');
cat('Output Filename:', output.filename, '\n');
cat('SV caller:', sv.caller, '\n');
cat('CNA caller:', cna.caller, '\n');
cat('Plot title:', plot.title, '\n');

source(paste0(script.source, '/convert-manta-to-circlize.R'));
source(paste0(script.source, '/convert-delly-to-circlize.R'));
source(paste0(script.source, '/circos-plot-setup.R'));

#### SPECIFY COLOR PALLETTE#########################################################################
sv.colors <- c('#008080', '#5d1f80', '#5d1f80', 'orangered1');
sv.colors.legend <- c('#008080', '#5d1f80', 'orangered1');
names(sv.colors) <- c('INV', 'BND', 'TRA', 'INS');

cna.3.colors <- c('red', 'blue','white');
names(cna.3.colors) <- c('gain', 'loss','neutral');

### INPUT ##########################################################################################
# read in input.vcf
vcf.object <- read.vcfR(input.vcf, verbose = FALSE)
sample <- sample.name
print('Successfully read in VCF file')

#### PROCESS SV ####################################################################################
if (sv.caller == 'DELLY') {
    print('Processing DELLY SVs\n')

    # Use DELLY conversion functions to extract SV data into dataframes
    otherSV.df <- convert.delly.otherSV.to.circlize(vcf = vcf.object, sample = sample);
    bnd.df.unfiltered <- convert.delly.BND.circlize(vcf = vcf.object, sample = sample);

    } else if (sv.caller == 'Manta') {
        print('Processing Manta SVs\n')

        # Use Manta conversion functions to extract SV data into dataframes
        otherSV.df <- convert.manta.otherSV.to.circlize(vcf = vcf.object, sample.id = sample);
        bnd.df.unfiltered <- convert.manta.BND.to.circlize(vcf = vcf.object, sample.id = sample);

        } else {
            stop('SV caller not recognised');
            }

# Subset dataframe based on SV type
dup.df <- otherSV.df[otherSV.df$type == 'DUP', ];
del.df <- otherSV.df[otherSV.df$type == 'DEL', ];
inv.df <- otherSV.df[otherSV.df$type == 'INV', ];
ins.df <- otherSV.df[otherSV.df$type == 'INS', ];
trans.df <- otherSV.df[otherSV.df$type == 'TRA',];
bnd.df <- bnd.df.unfiltered[bnd.df.unfiltered$type == 'BND', ];

# To distinguish INV and BND from Manta, if chr.start == chr.end, this is INV
bnd.df$type[bnd.df$chr.start == bnd.df$chr.end] <- 'INV';

# rbind() dataframes so the data for otherSV and BNDs are combined
sample.df <- rbind(
    dup.df,
    del.df,
    inv.df,
    ins.df,
    trans.df,
    bnd.df
    );

# Remove SVs that have 'random' or 'decoy' in the chromosome name
sample.df <- subset(sample.df, !grepl('random|decoy|alt|Un', chr.start));
sample.df <- subset(sample.df, !grepl('random|decoy|alt|Un', chr.end));

print('Successfully processed SV file')


#### PLOT CIRCOS ###################################################################################
# Initiate the circos plot
circos.clear();

# Set up the output filetype
if (output.type == 'png') {
    png(file = output.filename, width = 6, height = 6.5, units = 'in', res = 800)
    }
    if (output.type == 'pdf') {
        pdf(file = output.filename, width = 6, height = 9.5, units = 'in', res = 800)
        }
        if (output.type == 'jpeg') {
            jpeg(file = output.filename, width = 6, height = 9.5, units = 'in', res = 800)
            }
            if (output.type == 'tiff') {
                tiff(file = output.filename, width = 6, height = 9.5, units = 'in', res = 800)
                }

layout(matrix(c(1, 2), nrow = 2), heights = c(3, 0.4));

# Plot circos plot
par(mar = c(0, 1, 1, 1));
CIRCLIZE.SETUP();
CIRCLIZE.CHROMOSOME.LAYOUT();
list.of.InsInvBnd <- get.InsInvBnd.df(sample.df);
CIRCLIZE.INSINVBND(insinvbnd.list = list.of.InsInvBnd);

# Add a title to the plot
if (plot.title == TRUE) {
    title(sample, cex = 1.7, font = 2);
    }

plot.new();

legend(
    x = 'top',
    legend = c('Inversion','Breakend\nTranslocation','Insertion'),
    fill = sv.colors.legend,
    bty = 'n',
    border = NA,
    text.font = 1,
    cex = 0.9,
    title.font = 2,
    title.cex = 1.2,
    horiz = TRUE
    );

dev.off()
print('Successfully plotted circos')

### FIN ############################################################################################
