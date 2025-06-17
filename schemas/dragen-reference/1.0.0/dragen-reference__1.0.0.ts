import { FileProperties as IFile } from "cwl-ts-auto"

export enum Structure {
	"linear" = "linear",
	"graph" = "graph"
}

export interface DragenReference {
	/*
	name: 
	The name of the reference genome, i.e hg38
	*/
	name: string

	/*
	structure: 
	The structure of the reference genome, i.e. linear or graph
	*/
	structure: Structure

	/*
	tarball: 
	The reference tarball containing the reference genome and annotation files.
	*/
	tarball: IFile
}
