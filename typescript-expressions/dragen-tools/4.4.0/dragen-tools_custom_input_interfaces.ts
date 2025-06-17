/*
Some inputs are of mutually exclusive types that we cannot 'schemafy' in CWL,

Instead we type them here
*/

import {BamInput} from "../../../schemas/bam-input/1.0.0/bam-input__1.0.0";
import {BamOutput} from "../../../schemas/bam-output/1.0.0/bam-output__1.0.0";
import {CramInput} from "../../../schemas/cram-input/1.0.0/cram-input__1.0.0";
import {CramOutput} from "../../../schemas/cram-output/1.0.0/cram-output__1.0.0";
import {FastqListRowsInput} from "../../../schemas/fastq-list-rows-input/2.0.0/fastq-list-rows-input__2.0.0";
import {FileProperties as IFile} from "cwl-ts-auto";


export type DragenInputSequenceType = FastqListRowsInput | BamInput | CramInput

export type DragenInputAlignmentType = BamInput | CramInput
export type DragenOutputAlignmentType = BamOutput | CramOutput

export type StringOrFileType = string | IFile

