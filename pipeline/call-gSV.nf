#!/usr/bin/env nextflow

// Docker images here...
def docker_image_delly = "blcdsdockerregistry/call-gsv:delly-0.8.5"
def docker_image_bcftools = "blcdsdockerregistry/call-gsv:bcftools-X.X.X"

def number_of_cpus = (int) (Runtime.getRuntime().availableProcessors() / params.max_number_of_parallel_jobs)
if (number_of_cpus < 1) {
    number_of_cpus = 1
}
def total_memory = ((int) ((java.lang.management.ManagementFactory
    .getOperatingSystemMXBean()
    .getTotalPhysicalMemorySize() / (1024.0 * 1024.0 * 1024.0)) * 0.9))

// Log info here
log.info """\
        ======================================
        C A L L - G S V   N F  P I P E L I N E
        ======================================
        Boutros Lab

        Current Configuration:
        - input
            input_csv: ${params.input_csv}

        - output: 
            output a: ${params.output_path}
            ...

        - options:
            option a: ${params.option_name}
            ...

        Tools Used:
            delly: ${docker_image_delly}
            bcftools: ${docker_image_bcftools}

        ------------------------------------
        Starting workflow...
        ------------------------------------
        """
        .stripIndent()

// Channels here
// Decription of input channel
Channel
   .fromPath(params.input_csv)
   .ifEmpty { error "Cannot find input csv: ${params.input_csv}" }
   .splitCsv(header:true)
   .map { row -> 
       return tuple(row.row_1_name,
           row.row_2_name_file_extension
      )
   }
   .set { input_ch_input_csv }

// Decription of input channel
Channel
   .fromPath(params.variable_name)
   .ifEmpty { error "Cannot find: ${params.variable_name}" }
   .set { input_ch_variable_name }

// process here
// Decription of process
process tool_name_command_name {
   container docker_image_name

   publishDir params.output_dir, enabled: true, mode: 'copy'

   label "resource_allocation_tool_name_command_name"

   // Additional directives here
   
   input: 
      tuple(val(row_1_name), 
         path(row_2_name_file_extension),
      ) from input_ch_input_csv
      val(variable_name) from input_ch_variable_name

   output:
      file("${variable_name}.command_name.file_extension") into output_ch_tool_name_command_name

   script:
   """
   # make sure to specify pipefail to make sure process correctly fails on error
   set -euo pipefail

   # the script should ideally only have call to a tool
   # to make the command more human readable:
   #  - seperate components of the call out on different lines
   #  - when possible by explict with command options, spelling out their long names
   tool_name \
      command_name \
      --option_1_long_name ${row_1_name} \
      --input ${row_2_name_file_extension} \
      --output ${variable_name}.command_name.file_extension
   """
}
