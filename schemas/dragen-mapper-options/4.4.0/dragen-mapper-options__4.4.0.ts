export interface DragenMapperOptions {
	/*
	ann_sj_max_indel: 
	Specifies maximum indel length to expect near an annotated splice junction.
	*/
	ann_sj_max_indel?: number

	/*
	edit chain limit: 
	For edit-mode 1 or 2, the option sets maximum seed chain length in a read to qualify for seed editing.
	*/
	edit_chain_limit?: number

	/*
	edit_mode: 
	Controls when seed editing is used. The following values represent the different edit modes: 0 is no edits, 1 is chain length test, 2 is paired chain length test, 3 is full seed edits
	*/
	edit_mode?: number

	/*
	edit_read_len: 
	For edit-mode 1 or 2, controls the read length for edit-seed-num seed editing positions.
	*/
	edit_read_len?: number

	/*
	edit-seed-num: 
	For edit-mode 1 or 2, controls the requested number of seeds per read to allow editing on.
	*/
	edit_seed_num?: number

	/*
	map_orientations: 
	Restricts the orientation of read mapping to only forward in the reference genome or only reverse-complemented. The following values represent the different orientations (paired end requires normal):0 is normal (paired-end inputs must use normal), 1 is reverse-complemented, 2 is no forward
	*/
	map_orientations?: number

	/*
	max_intron_bases: 
	Specifies maximum intron length reported.
	*/
	max_intron_bases?: number

	/*
	min_intron_bases: 
	Specifies minimum reference deletion length reported as an intron.
	*/
	min_intron_bases?: number

	/*
	seed_density: 
	Controls requested density of seeds from reads queried in the hash table
	*/
	seed_density?: number
}
