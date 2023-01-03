import { BclconvertDataRow } from "../../bclconvert-data-row/4.0.3/bclconvert-data-row__4.0.3"
import { BclconvertSettings } from "../../bclconvert-settings/4.0.3/bclconvert-settings__4.0.3"
import { SamplesheetHeader } from "../../samplesheet-header/2.0.0/samplesheet-header__2.0.0"
import { SamplesheetReads } from "../../samplesheet-reads/2.0.0/samplesheet-reads__2.0.0"

export interface Samplesheet {
	/*
	BCLConvert Data section: 
	The array of bclconvert data objects
	*/
	bclconvert_data: BclconvertDataRow[]

	/*
	BCLConvert Settings section: 
	The bclconvert settings used for demux
	*/
	bclconvert_settings: BclconvertSettings

	/*
	samplesheet header: 
	The samplesheet header object
	*/
	header: SamplesheetHeader

	/*
	reads: 
	The reads
	*/
	reads: SamplesheetReads
}
