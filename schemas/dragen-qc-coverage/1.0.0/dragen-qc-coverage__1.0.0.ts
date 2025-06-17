import { FileProperties as IFile } from "cwl-ts-auto"

export enum ReportType {
	"full_res" = "full_res",
	"cov_report" = "cov_report"
}

export interface DragenQcCoverage {
	/*
	region: 
	Generate the coverage region report using this bed file
	*/
	region: IFile

	/*
	report type: 
	Describe the report type requested for qc coverage region
	*/
	report_type: ReportType

	/*
	thresholds: 
	Declare the thresholds to use in coverage report, up to 11 values
	*/
	thresholds?: number[]
}
