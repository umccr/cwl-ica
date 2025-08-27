import { FileProperties as IFile } from "cwl-ts-auto"

export interface DragenMsiOptions {
	/*
	msi command: 
	Mode of execution, one of tumor-only, tumor-normal, or collect-evidence
	*/
	msi_command?: string

	/*
	msi coverage threshold: 
	Minimum coverage threshold for microsatellite sites (default: 40)
	*/
	msi_coverage_threshold?: number

	/*
	msi microsatellites file: 
	Path to the microsatellites file
	*/
	msi_microsatellites_file?: IFile
}
