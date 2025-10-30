export interface DragenAlignerOptions {
	/*
	aln_min_score: 
	A signed integer that specifies a minimum acceptable alignment score to report the baseline for MAPQ. When using local alignments (global is 0), aln-min-score is computed by the host software as 22 * match-score. When using global alignments (global is 1), aln-min-score is set to -1000000. Host software computation can be overridden by setting aln-min-score in configuration file.
	*/
	aln_min_score: number

	/*
	clip_pe_overhang: 
	When nonzero, clips 3' read ends overhanging their mate's 5' ends as aligned. Set 1 to soft-clip overhang, 2 to hard-clip.
	*/
	clip_pe_overhang: number

	/*
	dedup_min_qual: 
	Specifies a minimum base quality for calculating read quality metric for deduplication.
	*/
	dedup_min_qual: number

	/*
	en_alt_hap_aln: 
	Allows haplotype alignments to be output as supplementary.
	*/
	en_alt_hap_aln: number

	/*
	en_chimeric_aln: 
	Allows chimeric alignments to be output as supplementary.
	*/
	en_chimeric_aln: number

	/*
	gap_ext_pen: 
	Specifies the penalty for extending a gap.
	*/
	gap_ext_pen: number

	/*
	gap_open_pen: 
	Specifies the penalty for opening a gap (ie, insertion or deletion).
	*/
	gap_open_pen: number

	/*
	global: 
	Controls whether alignment is end-to-end in the read. The following values represent the different alignments: 0 is local alignment (Smith-Waterman) 1 is global alignment (Needleman-Wunsch)
	*/
	global: number

	/*
	hard_clips: 
	Specifies alignments for hard clipping. The following values represent the different alignments: Bit 0 is primary Bit 1 is supplementary Bit 2 is secondary
	*/
	hard_clips: number

	/*
	map_orientations: 
	Constrains orientations to accept forward-only, reverse-complement only, or any alignments. The following values represent the different orientations: 0 is any 1 is forward only 2 is reverse only
	*/
	map_orientations: number

	/*
	mapq_max: 
	Specifies ceiling on reported MAPQ. The default value is 60.
	*/
	mapq_max: number

	/*
	mapq_strict_js: 
	Specific to RNA. When set to 0, a higher MAPQ value is returned, expressing confidence that the alignment is at least partially correct. When set to 1, a lower MAPQ value is returned, expressing the splice junction ambiguity.
	*/
	mapq_strict_js: number

	/*
	match_n_score: 
	A signed integer that specifies the score increment for matching where a read or reference base is N.
	*/
	match_n_score: number

	/*
	match_score: 
	Specifies the score increment for matching reference nucleotide.
	*/
	match_score: number

	/*
	max_rescues: 
	Specifies maximum rescue alignments per read pair. The default value is 10.
	*/
	max_rescues: number

	/*
	min_score_coeff: 
	Sets adjustment to aln-min-score per read base.
	*/
	min_score_coeff: number

	/*
	mismatch_pen: 
	Defines the score penalty for a mismatch.
	*/
	mismatch_pen: number

	/*
	no_unclip_score: 
	When set to 1, the option removes any unclipped bonus (unclip-score) contributing to an alignment from the alignment score before further processing.
	*/
	no_unclip_score: number

	/*
	no_unpaired: 
	Determines if only properly paired alignments should be reported for paired reads.
	*/
	no_unpaired: number

	/*
	pe_max_penalty: 
	Specifies the maximum pairing score penalty for unpaired or distant ends.
	*/
	pe_max_penalty: number

	/*
	pe_orientation: 
	Specifies the expected paired-end orientation. The following values represent the different orientations: 0 is FR (default) 1 is RF 2 is FF
	*/
	pe_orientation: number

	/*
	rescue_sigmas: 
	Sets deviations from the mean read length used for rescue scan radius. The default value is 2.5.
	*/
	rescue_sigmas: number

	/*
	sec_aligns: 
	Restricts the maximum number of secondary (suboptimal) alignments to report per read.
	*/
	sec_aligns: number

	/*
	sec_aligns_hard: 
	If set to 1, forces the read to be unmapped when not all secondary alignments can be output.
	*/
	sec_aligns_hard: number

	/*
	sec_phred_delta: 
	Controls which secondary alignments are emitted. Only secondary alignments within this Phred value of the primary are reported.
	*/
	sec_phred_delta: number

	/*
	sec_score_delta: 
	Determines the pair score threshold below primary that secondary alignments are allowed.
	*/
	sec_score_delta: number

	/*
	supp_aligns: 
	Restricts the maximum number of supplementary (chimeric) alignments to report per read.
	*/
	supp_aligns: number

	/*
	supp_as_sec: 
	Determines if supplementary alignments should be reported with secondary flag.
	*/
	supp_as_sec: number

	/*
	supp_min_score_adj: 
	Specifies amount to increase minimum alignment score for supplementary alignments. The score is computed by host software as 8 * match-score for DNA. The default is 0 for RNA.
	*/
	supp_min_score_adj: number

	/*
	unclip_score: 
	Specifies the score bonus for reaching the edge of the read.
	*/
	unclip_score: number

	/*
	unpaired_pen: 
	Specifies the penalty for unpaired alignments, using Phred scale.
	*/
	unpaired_pen: number
}
