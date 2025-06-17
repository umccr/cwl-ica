export interface DragenTargetedCallerOptions {
	/*
	Enable Targeted Caller: 
	The targeted caller can be enabled using the command line option --enable-targeted=true
	or a subset of targets can be enabled by providing a space-separated list of target names.
	The supported target names for WGS are: cyp2b6, cyp2d6, cyp21a2, gba, hba, lpa, rh, and smn.
	*/
	enable_targeted?: boolean | string[]
}
