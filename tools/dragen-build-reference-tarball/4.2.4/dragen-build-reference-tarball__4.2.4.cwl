cwlVersion: v1.1
class: CommandLineTool

# Extensions
$namespaces:
  s: https://schema.org/
  ilmn-tes: https://platform.illumina.com/rdf/ica/
$schemas:
  - https://schema.org/version/latest/schemaorg-current-http.rdf

# Metadata
s:author:
  class: s:Person
  s:name: Alexis Lucattini
  s:email: Alexis.Lucattini@umccr.org
  s:identifier: https://orcid.org/0000-0001-9754-647X

# ID/Docs
id: dragen-build-reference-tarball--4.2.4
label: dragen-build-reference-tarball v(4.2.4)
doc: |
  Documentation for dragen-build-reference-tarball v4.2.4

# ILMN V1 Resources Guide: https://illumina.gitbook.io/ica-v1/analysis/a-taskexecution#type-and-size
# ILMN V2 Resources Guide: https://help.ica.illumina.com/project/p-flow/f-pipelines#compute-types
hints:
  ResourceRequirement:
    ilmn-tes:resources/tier: standard
    ilmn-tes:resources/type: fpga
    ilmn-tes:resources/size: medium
    coresMin: 16
    ramMin: 240000
  DockerRequirement:
    dockerPull: 699120554104.dkr.ecr.us-east-1.amazonaws.com/public/dragen:4.2.4


requirements:
  ResourceRequirement:
    tmpdirMin: |
      ${
        /* 1 Tb */
        return Math.pow(2, 20); 
      }
  InlineJavascriptRequirement:
    expressionLib:
      - $include: ../../../typescript-expressions/dragen-tools/4.0.3/dragen-tools__4.0.3.cwljs
      - $include: ../../../typescript-expressions/utils/1.0.0/utils__1.0.0.cwljs
      - var get_hash_table_script_filename = function(){
          return "build_hash_table.sh";
        }
  InitialWorkDirRequirement:
    listing:
      - entryname: "$(get_hash_table_script_filename())"
        entry: |
          #!/usr/bin/env bash

          # Fail on non-zero exit of subshell
          set -euo pipefail

          # Create staging directory
          echo "Creating scratch directory at $(get_ref_scratch_dir(inputs.ht_reference.nameroot))" 1>&2
          mkdir -p "$(get_ref_scratch_dir(inputs.ht_reference.nameroot))"

          # Create output directory
          echo "Creating output directory at $(inputs.output_directory)" 1>&2
          mkdir -p "$(inputs.output_directory)"

          # Change to staging directory
          echo "Running dragen command at $(get_ref_scratch_dir(inputs.ht_reference.nameroot))" 1>&2

          # Run dragen command inside scratch dir
          ( \\
            cd "$(get_ref_scratch_dir(inputs.ht_reference.nameroot))" && \\
            "$(get_dragen_bin_path())" "\${@}" \\
          )
          # tar up output directory
          tar \\
            --directory "\$(dirname "$(inputs.output_directory)")" \\
            --create \\
            --gzip \\
            --file "$(inputs.output_directory).tar.gz" \\
            "$(inputs.output_directory)"

baseCommand: [ "bash" ]

arguments:
  - position: -1
    valueFrom: "$(get_hash_table_script_filename())"
  - prefix: "--build-hash-table"
    valueFrom: "true"

inputs:
  # Required inputs
  ht_reference:
    label: ht reference
    doc: |
      Reference fasta file
    type: File
    secondaryFiles:
      - pattern: ".fai"
        required: true
    inputBinding:
      prefix: --ht-reference
  output_directory:
    label: output directory
    doc: |
      The name of the dragen output directory.
      The output tarball will be this plus ".tar.gz"
    type: string
    inputBinding:
      prefix: "--output-directory"
      valueFrom: "$(runtime.outdir)/$(self)"
  #RNA hash input - setting default to true
  ht_build_rna_hashtable:
    label: ht build rna hash table
    doc: |
      Used when --enable-rna is set to true for any given dragen workflow.
      This option must be used when running dragen workflows on rna data.
    type: boolean?
    default: true
    inputBinding:
      prefix: "--ht-build-rna-hashtable"
      valueFrom: "$(self.toString())"
  ht_build_hla_hashtable:
    label: ht build hla hash table
    doc: |
      Used when --enable-hla is set to true for any given dragen workflow.
      This option must be used when running dragen workflows on hla data.
    type: boolean?
    default: true
    inputBinding:
      prefix: "--ht-build-hla-hashtable"
      valueFrom: "$(self.toString())"
  # Optional inputs
  # Seed and frequency length options
  ht_seed_len:
    label: ht primary seed length
    doc: |
      The --ht-seed-len option specifies the initial length in nucleotides
      of seeds from the reference genome to populate into the hash table.

      At run time, the mapper extracts seeds of this same length from each read,
      and looks for exact matches (unless seed editing is enabled) in the hash table.

      The maximum primary seed length is a function of hash table size.
      The limit is k=27 for table sizes from 16 GB to 64 GB, covering typical sizes for whole human genome,
      or k=26 for sizes from 4 GB to 16 GB.

      The minimum primary seed length depends mainly on the reference genome size and complexity.
      It needs to be long enough to resolve most reference positions uniquely.
      For whole human genome references, hash table construction typically fails with k < 16.
      The lower bound may be smaller for shorter genomes, or higher for less complex (more repetitive) genomes.
      The uniqueness threshold of --ht-seed-len 16 for the 3.1Gbp human
      genome can be understood intuitively because log4(3.1 G) ≈ 16,
      so it requires at least 16 choices from 4 nucleotides to distinguish 3.1 G reference positions.
    type: int?
    inputBinding:
      prefix: "--ht-seed-len"
  ht_max_ext_seed_len:
    label: ht maximum seed length
    doc: |
      The --ht-max-ext-seed-len option limits the length of extended seeds populated into the hash table.
      Primary seeds (length specified by --ht-seed-len) that match many reference positions can be extended
      to achieve more unique matching, which may be required to map seeds within the maximum hit frequency
      (--ht-max-seed-freq).
      Given a primary seed length k, the maximum seed length can be configured between k and k+128.
      The default is the upper bound, k+128.
    type: int?
    inputBinding:
      prefix: --ht-max-ext-seed-len
  ht_max_seed_freq:
    label: ht maximum hit frequency
    doc: |
      The --ht-max-seed-freq option sets a firm limit on the number of seed hits (reference genome locations)
      that can be populated for any primary or extended seed.

      If a given primary seed maps to more reference positions than this limit,
      it must be extended long enough that the extended seeds subdivide into smaller groups of identical
      seeds under the limit. If, even at the maximum extended seed length (--ht-max-ext-seed-len),
      a group of identical reference seeds is larger than this limit,
      their reference positions are not populated into the hash table.
      Instead, dragen populates a single High Frequency record.
      The maximum hit frequency can be configured from 1 to 256.
      However, if this value is too low, hash table construction can fail because too many seed extensions are needed.
      The practical minimum for a whole human genome reference, other options being default, is 8.
    type: int?
    inputBinding:
      prefix: "--ht-max-seed-freq"
  # Alt-aware lift over options
  ht_alt_liftover:
    label: ht alt aware liftover
    doc: |
      The --ht-alt-liftover option specifies the path to the liftover file to build an ALT-aware hash table.
      This option is required when building from a reference with ALT contigs.
      SAM liftover files for hg38DH and hg19 are provided in /opt/edico/liftover.

      For hg38 references, use bwa-kit_hs38DH_liftover.sam
      For hg19 references, use hg19_alt_liftover.sam
    type:
      - "null"
      - File
      - type: enum
        symbols:
          - "bwa-kit_hs38DH_liftover.sam"
          - "hg19_alt_liftover.sam"
    inputBinding:
      prefix: "--ht-alt-liftover"
      valueFrom: >-
        ${
          /*
          Not checking for null
          Only evaluated if not null
          */
          if(typeof(self) == "string"){
            /*
            Enum, of type string
            Returns the lift over dir plus file name
            */
            return get_liftover_dir() + self;
          }
          else {
            /*
            Of type File, return path
            */
            return self.path;
          }
        }
  ht_alt_aware_validate:
    label: ht alt aware validation
    doc: |
      When building hash tables from a reference that contains ALT-contigs,
      building with a liftover file is required.
      To disable this requirement, set the --ht-alt-aware-validate option to false.
    type: boolean?
    inputBinding:
      prefix: "--ht-alt-aware-validate"
      valueFrom: "$(self.toString())"
  ht_decoys:
    label: ht decoys path
    doc: |
      The DRAGEN software automatically detects the use of hg19 and hg38 references and
      adds decoys to the hash table when they are not found in the FASTA file.
      Use the --ht-decoys option to specify the path to a decoys file.
      The default is /opt/edico/liftover/hs_decoys.fa.
    type: string?
    inputBinding:
      prefix: "--ht-decoys"
  ht_suppress_decoys:
    label: ht suppress decoys
    doc: |
      Use the --ht-suppress-decoys option to suppress the use of the decoys file when building the hash table.
    type: boolean?
    inputBinding:
      prefix: "--ht-suppress-decoys"
      valueFrom: "$(self.toString())"
  # Or mask alts
  ht_mask_bed:
    label: ht mask bed
    doc: |
      Specifies the BED file for base masking.
    type:
      - "null"
      - File
      - type: enum
        symbols:
          - "hg38_alt_mask.bed"
    inputBinding:
      prefix: "--ht-mask-bed"
      valueFrom: >-
        ${
          /*
          Not checking for null
          Only evaluated if not null
          */
          if(typeof(self) == "string"){
            /*
            Enum, of type string
            Returns the lift over dir plus file name
            */
            return get_mask_dir() + self;
          }
          else {
            /*
            Of type File, return path
            */
            return self.path;
          }
        }
  # Graph mapper hash table options
  ht_pop_alt_contigs:
    label: ht population alternate contigs
    doc: |
      Specifies the path to the reference FASTA file with population alternate contigs.
      The standard reference FASTA is augmented with the population alternate contigs during hash table build.
      The population alternate contigs file must have a corresponding liftover SAM file.
      A population alternate contig file for hg38 reference is provided in /opt/edico/liftover (pop_altContig.fa.gz).
    type: File?
    inputBinding:
      prefix: "--ht-pop-alt-contigs"
  ht_pop_alt_liftover:
    label: ht population alternate liftover
    doc: |
      Specifies the path to the liftover file for the population alternate contigs.
      The liftover SAM file must have a corresponding population alternate contigs FASTA.
      A population alternate contig SAM liftover file for hg38 reference is provided in /opt/edico/liftover
      (pop_liftover.sam.gz).
    type: File?
    inputBinding:
      prefix: "--ht-pop-alt-liftover"
  ht_pop_snps:
    label: ht population snps
    doc: |
      Specifies the path to a VCF file containing unphased population SNPs.
      The standard reference FASTA is augmented with these SNPs as multibase codes during mapping-aligning.
      Each SNP entry in the VCF only requires the CHROM, POS, REF, ALT columns.
      The ALT column can have multiple comma-separated population SNP VCF for hg38 reference is
      provided in /opt/edico/liftover (pop_snps.vcf.gz).
    type: File?
    inputBinding:
      prefix: "--ht-pop-snps"
  # Dragen software options
  ht_num_threads:
    label: ht num threads
    doc: |
      The --ht-num-threads option determines the maximum number of worker CPU threads that are
      used to speed up hash table construction.
      The default for this option is 8, with a maximum of 32 threads allowed.
      If your server supports execution of more threads, it is recommended that you use the maximum.
    type: int?
    inputBinding:
      prefix: "--ht-num-threads"
  ht_max_table_chunks:
    label: ht max table chunks
    doc: |
      The --ht-max-table-chunks option controls the memory footprint during hash table construction by
      limiting the number of ~1 GB hash table chunks that reside in memory simultaneously.
      Each additional chunk consumes roughly twice its size (~2 GB) in system memory during construction.

      The hash table is divided into power-of-two independent chunks, of a fixed chunk size, X,
      which depends on the hash table size, in the range 0.5 GB < X ≤ 1 GB.

      For example, a 24 GB hash table contains 32 independent 0.75 GB chunks that can be constructed by parallel
      threads with enough memory and a 16 GB hash table contains 16 independent 1 GB chunks.

      The default is --ht-max-table-chunks equal to --ht-num-threads,
      but with a minimum default --ht-max-table-chunks of 8.

      It makes sense to have these two options match, because building one hash table chunk requires one chunk space
      in memory and one thread to work on it. Nevertheless, there are build-speed advantages to
      raising --ht-max-table-chunks higher than --ht-num-threads, or to raising --ht-num-threads higher
      than --ht-max-table-chunks.

      For example, the DRAGEN servers contain 24 cores that have hyperthreading enabled,
      so a value of 32 should be used. When using a higher value, adjust --ht-max-table-chunks needs to be adjusted
      as well. The servers have 128 GB of memory available.
    type: int?
    inputBinding:
      prefix: "--ht-max-table-chunks"
  # Size options
  ht_mem_limit:
    label: ht mem limit
    doc: |
      The --ht-mem-limit option controls the generated hash table size by specifying the DRAGEN board memory available
      for both the hash table and the encoded reference genome.
      The ‑‑ht‑mem-limit option defaults to 32 GB when the reference genome approaches WHG size,
      or to a generous size for smaller references. Normally there is little reason to override these defaults.
    type: int?
    inputBinding:
      prefix: "--ht-mem-limit"
  ht_size:
    label: ht size
    doc: |
      This option specifies the hash table size to generate,
      rather than calculating an appropriate table size from the reference genome size
      and the available memory (option --ht-mem-limit).
      Using default table sizing is recommended and using --ht-mem-limit is the next best choice.
    type: int?
    inputBinding:
      prefix: "--ht-size"
  # Seed Population Options
  ht_ref_seed_interval:
    label: ht reference seed interval
    doc: |
      The --ht-ref-seed-interval option defines the step size between positions of seeds in the reference
      genome populated into the hash table.

      An interval of 1 (default) means that every seed position is populated, 2 means 50% of positions are populated,
      etc. Noninteger values are supported, eg, 2.5 yields 40% populated.

      Seeds from a whole human reference are easily 100% populated with 32 GB memory on DRAGEN boards.
      If a substantially larger reference genome is used, change this option
    type: int?
    inputBinding:
      prefix: "--ht-ref-seed-interval"
  ht_soft_seed_freq_cap:
    label: ht soft seed frequency cap
    doc: |
      Seed thinning is an experimental technique to improve mapping performance in high-frequency regions.
      When primary seeds have higher frequency than the cap indicated by the --ht-soft-seed-freq-cap option,
      only a fraction of seed positions are populated to stay under the cap.

      The --ht-max-dec-factor option specifies a maximum factor by which seeds can be thinned.

      For example, --ht-max-dec-factor 3 retains at least 1/3 of the original seeds. --ht-max-dec-factor 1
      disables any thinning.

      Seeds are decimated in careful patterns to prevent leaving any long gaps unpopulated.

      The idea is that seed thinning can achieve mapped seed coverage in high frequency reference regions
      where the maximum hit frequency would otherwise have been exceeded.

      Seed thinning can also keep seed extensions shorter, which is also good for successful mapping.
      Based on testing to date, seed thinning has not proven to be superior to other accuracy optimization methods.
    type: float?
    inputBinding:
      prefix: "--ht-soft-seed-freq-cap"
  ht_max_dec_factor:
    label: ht max dec factor
    doc: |
      Seed thinning is an experimental technique to improve mapping performance in high-frequency regions.
      When primary seeds have higher frequency than the cap indicated by the --ht-soft-seed-freq-cap option,
      only a fraction of seed positions are populated to stay under the cap.

      The --ht-max-dec-factor option specifies a maximum factor by which seeds can be thinned.

      For example, --ht-max-dec-factor 3 retains at least 1/3 of the original seeds. --ht-max-dec-factor 1
      disables any thinning.

      Seeds are decimated in careful patterns to prevent leaving any long gaps unpopulated.

      The idea is that seed thinning can achieve mapped seed coverage in high frequency reference regions
      where the maximum hit frequency would otherwise have been exceeded.

      Seed thinning can also keep seed extensions shorter, which is also good for successful mapping.
      Based on testing to date, seed thinning has not proven to be superior to other accuracy optimization methods.
    type: float?
    inputBinding:
      prefix: "--ht-max-dec-factor"
  ht_rand_hit_hifreq:
    label: ht random hit hifreq
    doc: |
      Whenever a HIFREQ or EXTEND record is populated into the hash table, it stands in place of a
      large set of reference hits for a certain seed.
      Optionally, the hash table builder can choose a random representative of that set,
      and populate that HIT record alongside the HIFREQ or EXTEND record.

      Random sample hits provide alternative alignments that are very useful in estimating MAPQ accurately
      for the alignments that are reported.

      They are never used outside of this context for reporting alignment positions,
      because that would result in biased coverage of locations that happened to be selected
      during hash table construction.

      To include a sample hit, set --ht-rand-hit-hifreq to 1.
      The --ht-rand-hit-extend option is a minimum pre-extension hit count to include a sample hit, or zero to disable.
      Modifying these options is not recommended.
    type: int?
    inputBinding:
      prefix: "--ht-rand-hit-hifreq"
  ht_rand_hit_extend:
    label: ht rand hit extend
    doc: |
      Whenever a HIFREQ or EXTEND record is populated into the hash table, it stands in place of a
      large set of reference hits for a certain seed.
      Optionally, the hash table builder can choose a random representative of that set,
      and populate that HIT record alongside the HIFREQ or EXTEND record.

      Random sample hits provide alternative alignments that are very useful in estimating MAPQ accurately
      for the alignments that are reported.

      They are never used outside of this context for reporting alignment positions,
      because that would result in biased coverage of locations that happened to be selected
      during hash table construction.

      To include a sample hit, set --ht-rand-hit-hifreq to 1.
      The --ht-rand-hit-extend option is a minimum pre-extension hit count to include a sample hit, or zero to disable.
      Modifying these options is not recommended.
    type: int?
    inputBinding:
      prefix: "--ht-rand-hit-extend"
  # Seed Extension Control
  ht_target_seed_freq:
    label: target hit frequency
    doc: |
      The --ht-target-seed-freq option defines the ideal number of hits per seed for which seed extension should aim.
      Higher values lead to fewer and shorter final seed extensions, because shorter seeds tend to match more reference
      positions.
    type: int?
    inputBinding:
      prefix: "--ht-target-seed-freq"
  ht_cost_coeff_seed_len:
    label: cost coefficient for seed length
    doc: |
      The --ht-cost-coeff-seed-len option assigns the cost component for each base by which a seed is extended.
      Additional bases are considered a cost because longer seeds risk overlapping variants or sequencing errors and
      losing their correct mappings. Higher values lead to shorter final seed extensions.
    type: float?
    inputBinding:
      prefix: "--ht-cost-coeff-seed-len"
  ht_cost_coeff_seed_freq:
    label: cost coefficient for hit frequency
    doc: |
      The --ht-cost-coeff-seed-freq option assigns the cost component for the difference between
      the target hit frequency and the number of hits populated for a single seed.
      Higher values result primarily in high-frequency seeds being extended further to bring their frequencies down
      toward the target.
    type: float?
    inputBinding:
      prefix: "--ht-cost-coeff-seed-freq"
  ht_cost_penalty:
    label: cost penalty for seed extension
    doc: |
      The --ht-cost-penalty option assigns a flat cost for extending beyond the primary seed length.
      A higher value results in fewer seeds being extended at all.
      Current testing shows that zero (0) is appropriate for this parameter.
    type: float?
    inputBinding:
      prefix: "--ht-cost-penalty"
  ht_cost_penalty_incr:
    label: cost increment for extension step
    doc: |
      The --ht-cost-penalty-incr option assigns a recurring cost for each incremental seed extension step
      taken from primary to final extended seed length.
      More steps are considered a higher cost because extending in many small steps requires
      more hash table space for intermediate EXTEND records,
      and takes substantially more run time to execute the extensions.
      A higher value results in seed extension trees with fewer nodes,
      reaching from the root primary seed length to leaf extended seed lengths in fewer, larger steps.
    type: float?
    inputBinding:
      prefix: "--ht-cost-penalty-incr"
  # Miscell options
  ht_methylated:
    label: ht methylated
    doc: |
      DRAGEN methylation runs require building a special pair of hash tables with reference bases
      converted from C->T for one table, and G->A for the other.
      When running the hash table generation with the --ht-methylated option, these conversions are done automatically,
      and the converted hash tables are generated in a pair of subdirectories of the target directory
      specified with --output-directory.
      The subdirectories are named CT_converted and GA_converted, corresponding to the automatic base conversions.
      When using these hash tables for methylated alignment runs, refer to the original --output-directory and not
      to either of the automatically generated subdirectories.
    type: boolean?
    inputBinding:
      prefix: "--ht-methylated"
      valueFrom: "$(self.toString())"
  # Miscellaneous options
  enable_cnv:
    label: enable cnv
    doc: |
      For the DRAGEN CNV pipeline, the hashtable must be generated with the --enable-cnv option set to true,
      in addition to any other options required by other pipelines.
      When --enable-cnv is true, dragen generates an additional k-mer uniqueness map that the CNV algorithm uses to
      counteract mapability biases.
      The k-mer uniqueness map file only needs to be generated once per reference hashtable
      and takes about 1.5 hours per whole human genome.
    type: boolean?
    inputBinding:
      prefix: "--enable-cnv"
      valueFrom: "$(self.toString())"

outputs:
  dragen_reference_tar:
    label: dragen reference tar
    doc: |
      Output tarball containing the reference data
    type: File
    outputBinding:
      glob: "$(inputs.output_directory).tar.gz"

successCodes:
  - 0

