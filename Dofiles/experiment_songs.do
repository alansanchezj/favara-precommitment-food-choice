/*******************************************************************************
********************************************************************************

	Paper title: When choice matters: the asymmetric effects of precommitment 
	implementation on healthy food choice
	Authors: Marta Favara, Joanna Mihaylova, Alan Sanchez

	This version: 11 January 2026

	Purpose: This do-file generates all tables, figures and results of the 
	experiment

********************************************************************************
*******************************************************************************/

	clear all 
	set more off
	
* Set path
	global pdir "C:\Users\qehs1337\OneDrive - Nexus365"
	global path "$pdir\Replication files"
	cd "$path"

* Create log file
	qui log close
	log using "$path\Dofiles\WhenChoiceMattersJoEP", replace
	
* Data
	use "$path\Data\analytical_dataset_SONGS.dta", clear

* Output
	global outputs "$path\Output"
	global gr "$outputs\Graphs"
	global tab "$outputs\Tables"

* Create "Yes/No" label
	label define yesno_lbl 0 "No" 1 "Yes"

********************************************************************************

** Gave consent to participate in SONGS study **

********************************************************************************

	count 

* Participant committed to attending the lab/ 
* Participant gave consent for at least one test which is mandatory to be performed in the comm. centre 
* (i.e. anthropometrics, bldp, or blds)
	gen commit_attend_lab = 0
	replace commit_attend_lab = 1 if consent_anthro==1 | consent_blds ==1 | consent_bldp==1
	label values commit_attend_lab yesno_lbl
	label var commit_attend_lab "Committed to attend community centre"
	tab commit_attend_lab, m 
	
* Figure A.1 
	table (var) (), ///
	statistic(fvfreq consent_main consent_anthro consent_blds consent_bldp commit_attend_lab snack) ///
	statistic(fvpercent consent_main consent_anthro consent_blds consent_bldp commit_attend_lab snack)

	collect style cell var[consent_main consent_anthro consent_blds consent_bldp commit_attend_lab snack]#result[fvfrequency], nformat(%6.0fc)
	collect style cell var[consent_main consent_anthro consent_blds consent_bldp commit_attend_lab snack]#result[fvpercent], nformat(%6.1f) sformat("%s%%")	

	collect style header result, level(hide)
	collect style row stack, nobinder indent
	collect style cell border_block, border(right, pattern(nil))

	collect notes "Note: The data for this table were collected as part of the SONGS round (2022) of the Young Lives study in Peru."

	collect preview

	collect style putdocx, layout(autofitcontents) title("SONGS Consent")
	collect export "$tab/experiment_consent.docx", as(docx) replace

********************************************************************************

** Study Sample **

********************************************************************************

	describe gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same 

* Create final sample (i.e., exclude any observations with any missings for the main variables)
	reg gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same 

	gen included_in_model = e(sample)

* Summarize included observations
	summarize if included_in_model == 1
* Summarize dropped observations
	summarize if included_in_model == 0
	misstable sum gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same if included_in_model == 0	

	gen sample=0
	replace sample=1 if e(sample)
	label val sample yesno_lbl 
	label var sample "Final sample"
	fre sample

********************************************************************************

** Summary Statistics **

********************************************************************************

	unab varlist : gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same 
	foreach var of local varlist {
	tab sample `var', m
	}

* Compare non-analytic vs analytic samples (123 vs. 710)
* ssc install estout, replace 

	tab wi_terc5, gen(wi_terc5_d)
	tab participant_education_3, generate(participant_education_3_d)
	tab drinks_call5, generate(drinks_call5_d)
	tab snacks_call5, generate(snacks_call5_d) 

	local desvars age gender mumlang_r2 wi_terc5_d* educ_curr participant_education_3_d* job_curr ///
              excess drinks_call5_d* snacks_call5_d* activecov5
	unab desvars : `desvars'

* Run t-tests for all variables by 'sample'
	estpost ttest `desvars', by(sample)

* Table A.1 
	esttab using "$tab/experiment_analytic_vs_non_descriptive_stats.csv", ///
    cells("mu_1(fmt(3)) mu_2(fmt(3)) b(fmt(3) star)") ///
    collabels("Mean (Non-analytic)" "Mean (Analytic)" "Diff.") ///
    label replace title("Table A1: Differences between participants in the non-analytic versus analytic samples") ///
    addnotes("Note: Results from t-tests are reported in column three. Differences that are statistically significant at the 5% 1% and 0.1% are reported as (*) (**) and (***) respectively. N = 123 for the non-analytic sample and N = 710 for the analytic sample.") ///
    star(* 0.05 ** 0.01 *** 0.001) noobs
	
* Keep only the analytical sample 
	drop if sample==0
	count 

* Table 1 
	table (var),                            ///
    statistic(frequency) statistic(percent) ///
	statistic(mean age) statistic(sd age) ///
	statistic(mean gender) statistic(sd gender) ///
	statistic(fvfreq mumlang_r2) statistic(fvperc mumlang_r2) /// 
	statistic(fvfreq wi_terc5) statistic(fvperc wi_terc5) ///
	statistic(fvfreq educ_curr) statistic(fvperc educ_curr) ///
	statistic(fvfreq participant_education_3) statistic(fvperc participant_education_3) /// 
	statistic(fvfreq job_curr) statistic(fvperc job_curr) ///
	statistic(fvfreq excess) statistic(fvperc excess) ///
	statistic(fvfreq drinks_call5) statistic(fvperc drinks_call5) ///
	statistic(fvfreq snacks_call5) statistic(fvperc snacks_call5) ///
	statistic(mean activecov5) statistic(sd activecov5) ///

	collect recode result 	fvfrequency = column1 ///
						fvpercent   = column2 ///
						mean        = column1 ///
						sd          = column2 
	
	collect layout (var) (result[column1 column2])	

	collect style cell var[wi_terc5 mumlang_r2 educ_curr participant_education_3 job_curr excess drinks_call5 snacks_call5]#result[column1], nformat(%6.0fc)
	collect style cell var[age gender activecov5]#result[column1], nformat(%6.1f)
	collect style cell result[column2], nformat(%6.1f)

	collect style header result, level(hide)
	collect style row stack, nobinder indent
	collect style cell border_block, border(right, pattern(nil))

	collect notes "Notes: Data comes from multiple rounds: mother's first language (Round 2, 2006); wealth index tercile (Round 5, 2016); sugary drink and salty snack consumption, and exercise frequency (Round 6, 2021); age, sex, whether currently enrolled in full-time education, current/highest education level, whether currently has a job, and overweight/obese (SONGS, 2022)."

	collect preview

	collect style putdocx, layout(autofitcontents) title("Table 1: Summary statistics")
	collect export "$tab/experiment_study_sample_descriptive_stats.docx", as(docx) replace

********************************************************************************

** Exploratory Analysis ** Figure 2

********************************************************************************

	fre choice_H
	fre choice_NH

	fre choice_today
	
* Healthy snack choice ex-ante 
	fre register_choice if choice_today == 1 
	di((356/710)*100) // 50.1% pre-commit there healthy snack choice ex-ante
	di((133/710)*100) // 18.7% did not pre-commit there healthy snack choice ex-ante
	
	fre outcome_registered if choice_today == 1 & register_choice == 1
	di((216/710)*100) // 30.4% had their choice (i.e. to pre-commit) implemented
	di((140/710)*100) // 19.7% had their choice (i.e. to pre-commit) not implemented
	fre outcome_registered if choice_today == 1 & register_choice == 0
	di((74/710)*100) // 10.4% had their choice (i.e. decide at the comm. centre) implemented
	di((59/710)*100) // 8.3% had their choice (i.e. decide at the comm. centre) not implemented
	
* Unhealthy snack choice ex-ante 
	fre register_choice if choice_today == 2 
	di((130/710)*100) // 18.3% pre-commit there unhealthy snack choice ex-ante
	di((91/710)*100) // 12.8% did not pre-commit there unhealthy snack choice ex-ante
	
	fre outcome_registered if choice_today == 2 & register_choice == 1
	di((83/710)*100) // 11.7% had their choice (i.e. to pre-commit) implemented
	di((47/710)*100) // 6.6% had their choice (i.e. to pre-commit) not implemented
	fre outcome_registered if choice_today == 2 & register_choice == 0
	di((57/710)*100) // 8% had their choice (i.e. decide at the comm. centre) implemented
	di((34/710)*100) // 4.8% had their choice (i.e. decide at the comm. centre) not implemented

********************************************************************************

** Exploratory Analysis ** Table A.2

********************************************************************************

* AA
	preserve 
	keep if register_choice==1 & treatment_imp==0
	tab choice_today snack_choice
	restore 
	// n = 299
	di((216/299)*100) // 72% chose healthy 

* AI
	preserve
	keep if register_choice==1 & treatment_imp==1
	tab choice_today snack_choice
	restore
	// n = 187
	di((140/187)*100) // 75% chose healthy 
	di((17/140)*100) // 12% changed from healthy to unhealthy
	di((10/47)*100) // 21% changed from unhealthy to healthy

* IA
	preserve
	keep if register_choice==0 & treatment_imp==1
	tab choice_today snack_choice
	restore
	// n = 93
	di((59/93)*100) // 63% chose healthy 

* II
	preserve
	keep if register_choice==0 & treatment_imp==0
	tab choice_today snack_choice
	restore
	// n = 131
	di((74/131)*100) // 56% chose healthy
	di((26/74)*100) // 35% changed from healthy to unhealthy
	di((22/57)*100) // 39% changed from unhealthy to healthy

********************************************************************************

** Evaluations of snack choices ** Figures A.3 and A.4

********************************************************************************

* Stacked bar chart of participants' ratings of snack healthiness
	
	preserve 

	foreach i of numlist 1/5 {
		gen healthy_H1_`i' = (healthy_H1 == `i')
	}
	
	graph bar (mean) healthy_H1_1 healthy_H1_2 healthy_H1_3 healthy_H1_4 healthy_H1_5, stack percent ///
    title("Healthy 1") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\healthy_H1.gph", replace

	foreach i of numlist 1/5 {
		gen healthy_H2_`i' = (healthy_H2 == `i')
	}
	
	graph bar (mean) healthy_H2_1 healthy_H2_2 healthy_H2_3 healthy_H2_4 healthy_H2_5, stack percent ///
    title("Healthy 2") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\healthy_H2.gph", replace

	foreach i of numlist 1/5 {
		gen healthy_NH1_`i' = (healthy_NH1 == `i')
	}
	
	graph bar (mean) healthy_NH1_1 healthy_NH1_2 healthy_NH1_3 healthy_NH1_4 healthy_NH1_5, stack percent ///
    title("Unhealthy 1") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\healthy_NH1.gph", replace
	
	foreach i of numlist 1/5 {
		gen healthy_NH2_`i' = (healthy_NH2 == `i')
	}
	
	graph bar (mean) healthy_NH2_1 healthy_NH2_2 healthy_NH2_3 healthy_NH2_4 healthy_NH2_5, stack percent ///
    title("Unhealthy 2") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\healthy_NH2.gph", replace
	
	graph combine "$gr\healthy_H1.gph" "$gr\healthy_H2.gph" ///
	"$gr\healthy_NH1.gph" "$gr\healthy_NH2.gph", rows(1)
	graph export "$gr\healthy_snack_bar.png", replace
		
	restore

* Stacked bar chart of participants' ratings of snack enjoyment

	preserve 

	foreach i of numlist 1/5 {
		gen enjoy_H1_`i' = (enjoy_H1 == `i')
	}
	
	graph bar (mean) enjoy_H1_1 enjoy_H1_2 enjoy_H1_3 enjoy_H1_4 enjoy_H1_5, stack percent ///
    title("Healthy 1") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\enjoy_H1.gph", replace

	foreach i of numlist 1/5 {
		gen enjoy_H2_`i' = (enjoy_H2 == `i')
	}
	
	graph bar (mean) enjoy_H2_1 enjoy_H2_2 enjoy_H2_3 enjoy_H2_4 enjoy_H2_5, stack percent ///
    title("Healthy 2") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\enjoy_H2.gph", replace

	foreach i of numlist 1/5 {
		gen enjoy_NH1_`i' = (enjoy_NH1 == `i')
	}
	
	graph bar (mean) enjoy_NH1_1 enjoy_NH1_2 enjoy_NH1_3 enjoy_NH1_4 enjoy_NH1_5, stack percent ///
    title("Unhealthy 1") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\enjoy_NH1.gph", replace
	
	foreach i of numlist 1/5 {
		gen enjoy_NH2_`i' = (enjoy_NH2 == `i')
	}
	
	graph bar (mean) enjoy_NH2_1 enjoy_NH2_2 enjoy_NH2_3 enjoy_NH2_4 enjoy_NH2_5, stack percent ///
    title("Unhealthy 2") ytitle("Percent") legend(off) ///
    bar(1, color(maroon)) ///
    bar(2, color(orange_red)) ///
    bar(3, color(orange)) ///
    bar(4, color(lime)) ///
    bar(5, color(green)) 
	graph save "$gr\enjoy_NH2.gph", replace
	
	graph combine "$gr\enjoy_H1.gph" "$gr\enjoy_H2.gph" "$gr\enjoy_NH1.gph" "$gr\enjoy_NH2.gph", rows(1)
	graph export "$gr\enjoy_snack_bar.png", replace
		
	restore
	
********************************************************************************

** Balance Tables ** Table A.3

********************************************************************************

* Check randomisation for "Treatment: show note"
	iebaltab age gender mumlang_r2 wi5 educ_curr participant_education_3_d1 participant_education_3_d2 participant_education_3_d3 job_curr ///
	excess high_consumption exercise_call5 confidence_dummy_bf choice_after_H choice_same certainty_dummy , ///
	grpvar(treatment_note) ///
	savexlsx("$tab/treatment_information_bal.xlsx") replace ///
	stats(pair(p)) star(.05 .01 .001) ///
	grpl(0 "Control (no rationale)" 1 "Treated (rationale)") ///
	rowv vce(robust) total nonote

* Check randomisation for "Treatment: cannot implement preferred option"
	iebaltab age gender mumlang_r2 wi5 educ_curr participant_education_3_d1 participant_education_3_d2 participant_education_3_d3 job_curr ///
	excess high_consumption exercise_call5 confidence_dummy_bf choice_after_H choice_same certainty_dummy treatment_note register_choice, ///
	grpvar(treatment_imp) ///
	savexlsx("$tab/treatment_choice_override_bal.xlsx") replace ///
	stats(pair(p)) star(.05 .01 .001) ///
	grpl(0 "Control (choice implement)" 1 "Treated (choice override)") ///
	rowv vce(robust) total nonote

********************************************************************************

** Table 2: Effect of Treatment: Show Note ** 

********************************************************************************

	estimates clear

* Specification (1)

	eststo: reg register_choice treatment_note##choice_today_H i.Site, vce(cluster Site)
	
	matrix list e(b)
	margins choice_today_H, dydx(treatment_note)

	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.treatment_note] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.choice_today_H] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.treatment_note#1.choice_today_H] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 1 + Beta 3
	boottest "_b[1.treatment_note] + _b[1.treatment_note#1.choice_today_H] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph
		
* Specification (2)

	eststo: reg register_choice treatment_note##choice_today_H ///
	gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site, vce(cluster Site)

	matrix list e(b)
	margins choice_today_H, dydx(treatment_note)

	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.treatment_note] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.choice_today_H] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.treatment_note#1.choice_today_H] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 1 + Beta 3
	boottest "_b[1.treatment_note] + _b[1.treatment_note#1.choice_today_H] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph

* Specification (3)

	eststo: reg register_choice treatment_note##choice_today_H ///
	gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same i.Site, vce(cluster Site)

	matrix list e(b)
	margins choice_today_H, dydx(treatment_note)

	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.treatment_note] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.choice_today_H] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.treatment_note#1.choice_today_H] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 1 + Beta 3
	boottest "_b[1.treatment_note] + _b[1.treatment_note#1.choice_today_H] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph


	esttab using "$tab/treatment_information_reg.csv", cells (b(star fmt(%9.3f)) se(par fmt(%9.2f)) )  ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R-squared)) ///
	label collabels(none) nodepvars star(* 0.05 ** 0.01 *** 0.001) compress ///
	note("DV = Participant received a healthy snack") ///
	nobaselevels replace

********************************************************************************

** Figure A5: Motives for pre-commitment **

********************************************************************************

* Healthy 'today'

    foreach var of varlist reason1 reason2 reason3 reason4 reason5 {
	tab `var' if register_choice==1 & choice_today_H==1, m
	}
 
 	preserve
	
	drop if choice_today_H!=1
	keep reason* childcode
	drop reason6 // other (specify)
	drop reason2 // response option not offered to those with choice_today_H==1
	
	reshape long reason, i(childcode) j(cat)
	label define cat 					///
		  5 "Do not mind"				///
		  4 "Pressured"			        ///
		  3 "Not be tempted"		    ///
		  2 "Not feel guilty"			/// (not inc. since all obs give missing)
		  1 "Simplify decisions"	
	label val cat cat
	tab cat reason
	
	floatplot reason, over(cat) center(0) ytitle("") scale(*.8) 			///
			  fcolors(maroon maroon*0.5 dkgreen*0.5 dkgreen) format(%0.0f)	///
			  xlabel(0 25 50 75 100, labsize(medlarge)) ///
			  xtitle("Percent", size(medlarge)) ///
			  ylabel(, labsize(medlarge)) ///
			  legend(order(1 "Strongly disagree" 2 "Disagree" 3 "Agree" 4 "Strongly agree") ///
              size(medlarge) col(4) region(lcolor(none) fcolor(none)))
			  
	graph export "$gr/commitment_H_motive.png", replace
	
	restore

* Unhealthy 'today'

    foreach var of varlist reason1 reason2 reason3 reason4 reason5 {
	tab `var' if register_choice==1 & choice_today_H==0, m
	}

    preserve
	
	drop if choice_today_H!=0
	keep reason* childcode
	drop reason6 // other (specify)
	drop reason3 // response option not offered to those with choice_today_H==0
	
	reshape long reason, i(childcode) j(cat)
	label define cat 					///
		  5 "Do not mind"				///
		  4 "Pressured"			        ///
		  3 "Not be tempted"			/// (not inc. since all obs give missing)
		  2 "Not feel guilty"		    /// 
		  1 "Simplify decisions"	
	label val cat cat
	tab cat reason
	
	floatplot reason, over(cat) center(0) ytitle("") scale(*.8) 			///
			  fcolors(maroon maroon*0.5 dkgreen*0.5 dkgreen) format(%0.0f)	///
			  xlabel(0 25 50 75 100, labsize(medlarge)) ///
			  xtitle("Percent", size(medlarge))  ///
			  ylabel(,labsize(medlarge)) ///
			  legend(order(1 "Strongly disagree" 2 "Disagree" 3 "Agree" 4 "Strongly agree") ///
              size(medlarge) col(4) region(lcolor(none) fcolor(none)))
	
	graph export "$gr/commitment_UH_motive.png", replace
	
	restore

********************************************************************************

** Figure A6: Motives for not committing **

********************************************************************************

* Healthy 'today'

    foreach var of varlist reason_not1 reason_not2 reason_not3 reason_not4 reason_not5 {
	tab `var' if register_choice==0 & choice_today_H==1, m
	} 
	
    preserve
	
	drop if choice_today_H!=1
	keep reason_not* childcode
	drop reason_not6
	
	reshape long reason_not, i(childcode) j(cat)
	label define cat 					///
		  5 "Do not mind"				///
		  4 "Pressured"			        ///
		  3 "Learn"				        ///
		  2 "Keep options"				/// 
		  1 "Like to be free"	
	label val cat cat
	tab cat reason_not
	
	floatplot reason_not, over(cat) center(0) ytitle("") scale(*.8) 			///
			  fcolors(maroon maroon*0.5 dkgreen*0.5 dkgreen) format(%0.0f)	///
			  xlabel(0 25 50 75 100, labsize(medlarge)) xtitle("Percent", size(medlarge)) ///
			  ylabel(,labsize(medlarge)) ///
			  legend(order(1 "Strongly disagree" 2 "Disagree" 3 "Agree" 4 "Strongly agree") ///
              size(medlarge) col(4) region(lcolor(none) fcolor(none)))
			  
	graph export "$gr/choose_tomorrow_H_motive.png", replace
	
	restore
	
* Unhealthy 'today'

    foreach var of varlist reason_not1 reason_not2 reason_not3 reason_not4 reason_not5 {
	tab `var' if register_choice==0 & choice_today_H==0, m
	} 
	
    preserve
	
	drop if choice_today_H!=0
	keep reason_not* childcode
	drop reason_not6
	
	reshape long reason_not, i(childcode) j(cat)
	label define cat 					///
		  5 "Do not mind"				///
		  4 "Pressured"			        ///
		  3 "Learn"				        ///
		  2 "Keep options"				/// 
		  1 "Like to be free"	
	label val cat cat
	tab cat reason_not
	
	floatplot reason_not, over(cat) center(0) ytitle("") scale(*.8) 			///
			  fcolors(maroon maroon*0.5 dkgreen*0.5 dkgreen) format(%0.0f)	///
			  xlabel(0 25 50 75 100, labsize(medlarge)) xtitle("Percent", size(medlarge)) ///
			  ylabel(,labsize(medlarge)) ///
			  legend(order(1 "Strongly disagree" 2 "Disagree" 3 "Agree" 4 "Strongly agree") ///
              size(medlarge) col(4) region(lcolor(none) fcolor(none)))
	
	graph export "$gr/choose_tomorrow_UH_motive.png", replace
	
	restore

********************************************************************************

** Effect of Treatment: Cannot implement preferred option ** Table 3 
** Note: Table 3 reports specification (3) results from Online Appendix Tables A.4 and A.5 **

********************************************************************************

* Group: chose a healthy snack 'today' (Table A.4)

	estimates clear

	* Specification (1)
	
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	
	margins register_choice, dydx(treatment_imp) 

	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.register_choice] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.register_choice#1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 + Beta 3
	boottest "_b[1.treatment_imp] + _b[1.register_choice#1.treatment_imp] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph

	* Specification (2)
	
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp ///
	gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==1, vce(cluster Site)
	
	margins register_choice, dydx(treatment_imp)
	
	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.register_choice] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.register_choice#1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 + Beta 3
	boottest "_b[1.treatment_imp] + _b[1.register_choice#1.treatment_imp] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph
	
	* Specification (3)
	
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp ///
	gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same ///
	i.Site if choice_today==1, vce(cluster Site)
	
	margins register_choice, dydx(treatment_imp)
	 
	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.register_choice] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.register_choice#1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 + Beta 3
	boottest "_b[1.treatment_imp] + _b[1.register_choice#1.treatment_imp] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph
	
	esttab using "$tab/treatment_choice_override_H_reg.csv", cells (b(star fmt(%9.3f)) se(par fmt(%9.2f)))  ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R-squared)) ///
	label collabels(none) nodepvars star(* 0.05 ** 0.01 *** 0.001) compress ///
	note("DV = Participant received a healthy snack") ///
	nobaselevels replace

* Group: chose an unhealthy snack 'today' (Table A.5)

	estimates clear

	* Specification (1)
	
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp i.Site if choice_today==2, vce(cluster Site)
	
	margins register_choice, dydx(treatment_imp) 
	
	di as text "---- Wild cluster bootstrap p-values for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.register_choice] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.register_choice#1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 + Beta 3
	boottest "_b[1.treatment_imp] + _b[1.register_choice#1.treatment_imp] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph
	
	* Specification (2)
	
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp ///
	gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==2, vce(cluster Site)
	
	margins register_choice, dydx(treatment_imp)

	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.register_choice] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.register_choice#1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 + Beta 3
	boottest "_b[1.treatment_imp] + _b[1.register_choice#1.treatment_imp] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph
	
	* Specification (3)
	
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp ///
	gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same ///
	i.Site if choice_today==2, vce(cluster Site)
	
	margins register_choice, dydx(treatment_imp)

	di as text "---- Wild cluster bootstrap p-value for coefficients and marginal effects ----"
	*Beta 1
	boottest _b[1.register_choice] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 
	boottest _b[1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 3
	boottest _b[1.register_choice#1.treatment_imp] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 0
	boottest _b[_cons] = 0, cluster(Site) reps(1999) ptype(equal) seed(12345) nograph
	*Beta 2 + Beta 3
	boottest "_b[1.treatment_imp] + _b[1.register_choice#1.treatment_imp] = 0", cluster(Site) ///
	reps(1999) ptype(equal) seed(12345) nograph
	
	esttab using "$tab/treatment_choice_override_UH_reg.csv", cells (b(star fmt(%9.3f)) se(par fmt(%9.2f)))  ///
	stats(r2 N, fmt(%9.3f %9.0g) labels(R-squared)) ///
	label collabels(none) nodepvars star(* 0.1 ** 0.05 *** 0.01) compress ///
	note("DV = Participant received a healthy snack") ///
	nobaselevels replace
	
********************************************************************************

** Heterogeneity by Health Status ** Table A.6

********************************************************************************
********************************************************************************
** Heterogeneity by health status (excess) **
** Effect of Treatment: Show Note ** 
** (Underweight or normal weight versus overweight or obese) **

	estimates clear

* Specification (1)
	eststo: reg register_choice treatment_note##choice_today_H##excess i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5  ([IT|Hex-ante=0, excess=1]-[IT|Hex-ante=0,excess=0])
	test 1.treatment_note#1.excess = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, excess=1]-[IT|Hex-ante=1,excess=0])
	test 1.treatment_note#1.excess + 1.treatment_note#1.choice_today_H#1.excess = 0 // not sig.
	margins excess#choice_today_H, dydx(treatment_note)

* Specification (2)
	eststo: reg register_choice treatment_note##choice_today_H##excess gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5  ([IT|Hex-ante=0, excess=1]-[IT|Hex-ante=0,excess=0])
	test 1.treatment_note#1.excess = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, excess=1]-[IT|Hex-ante=1,excess=0])
	test 1.treatment_note#1.excess + 1.treatment_note#1.choice_today_H#1.excess = 0 // not sig.
	margins excess#choice_today_H, dydx(treatment_note)

* Specification (3)
	eststo: reg register_choice treatment_note##choice_today_H##excess gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5  ([IT|Hex-ante=0, excess=1]-[IT|Hex-ante=0,excess=0])
	test 1.treatment_note#1.excess = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, excess=1]-[IT|Hex-ante=1,excess=0])
	test 1.treatment_note#1.excess + 1.treatment_note#1.choice_today_H#1.excess = 0 // not sig.
	margins excess#choice_today_H, dydx(treatment_note)

********************************************************************************
** Heterogeneity by health status (high_consumption) **
** Effect of Treatment: Show Note ** 
** (high consumption of salty snacks or sugary drinks versus 
** low consumption of salty snacks and sugary drinks) **

	fre snacks_call5 drinks_call5
	tab snacks_call5 drinks_call5, m
	
	tab high_consumption // 261 low consumption (37%) & 449 high consumption (63%)
	tab high_consumption high_snack
	tab high_consumption high_drink

	estimates clear

* Specification (1)
	eststo: reg register_choice treatment_note##choice_today_H##high_consumption i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5 ([IT|Hex-ante=0, high consumption=1]-[IT|Hex-ante=0,high consumption=0])
	test 1.treatment_note#1.high_consumption = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, high consumption=1]-[IT|Hex-ante=1,high consumption=0])
	test 1.treatment_note#1.high_consumption + 1.treatment_note#1.choice_today_H#1.high_consumption = 0 // not sig.
	margins high_consumption#choice_today_H, dydx(treatment_note)

* Specification (2)
	eststo: reg register_choice treatment_note##choice_today_H##high_consumption gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5 ([IT|Hex-ante=0, high consumption=1]-[IT|Hex-ante=0,high consumption=0])
	test 1.treatment_note#1.high_consumption = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, high consumption=1]-[IT|Hex-ante=1,high consumption=0])
	test 1.treatment_note#1.high_consumption + 1.treatment_note#1.choice_today_H#1.high_consumption = 0 // not sig.
	margins high_consumption#choice_today_H, dydx(treatment_note)

* Specification (3)
	eststo: reg register_choice treatment_note##choice_today_H##high_consumption gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess activecov5 confidence_future_bf choice_after_H choice_same i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5 ([IT|Hex-ante=0, high consumption=1]-[IT|Hex-ante=0,high consumption=0])
	test 1.treatment_note#1.high_consumption = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, high consumption=1]-[IT|Hex-ante=1,high consumption=0])
	test 1.treatment_note#1.high_consumption + 1.treatment_note#1.choice_today_H#1.high_consumption = 0 // not sig.
	margins high_consumption#choice_today_H, dydx(treatment_note)

********************************************************************************
** Heterogeneity by health status (exercise_call5) **
** Effect of Treatment: Show Note ** 
** (physically active versus inactive) **

	estimates clear

* Specification (1)
	eststo: reg register_choice treatment_note##choice_today_H##exercise_call5 i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5 ([IT|Hex-ante=0, physically active=1]-[IT|Hex-ante=0,physically active=0])
	test 1.treatment_note#1.exercise_call5 = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, physically active=1]-[IT|Hex-ante=1,physically active=0])
	test 1.treatment_note#1.exercise_call5 + 1.treatment_note#1.choice_today_H#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#choice_today_H, dydx(treatment_note)

* Specification (2)
	eststo: reg register_choice treatment_note##choice_today_H##exercise_call5 gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5 ([IT|Hex-ante=0, physically active=1]-[IT|Hex-ante=0,physically active=0])
	test 1.treatment_note#1.exercise_call5 = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, physically active=1]-[IT|Hex-ante=1,physically active=0])
	test 1.treatment_note#1.exercise_call5 + 1.treatment_note#1.choice_today_H#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#choice_today_H, dydx(treatment_note)

* Specification (3)
	eststo: reg register_choice treatment_note##choice_today_H##exercise_call5 gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 excess ///
	snacks_call5 drinks_call5 confidence_future_bf choice_after_H choice_same i.Site, vce(cluster Site)
	matrix list e(b)
	// beta 5 ([IT|Hex-ante=0, physically active=1]-[IT|Hex-ante=0,physically active=0])
	test 1.treatment_note#1.exercise_call5 = 0 // not sig.
	// beta 5 + beta 7 ([IT|Hex-ante=1, physically active=1]-[IT|Hex-ante=1,physically active=0])
	test 1.treatment_note#1.exercise_call5 + 1.treatment_note#1.choice_today_H#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#choice_today_H, dydx(treatment_note)

********************************************************************************
** Heterogeneity by health status (excess) **
** Effect of Treatment: Cannot implement preferred option ** 
** (Underweight or normal weight versus overweight or obese) **

* Group: chose a healthy snack ex-ante

	estimates clear

* Specification (1)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.excess i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, excess=1]-[CO|PC=0,excess=0])
	test 1.treatment_imp#1.excess = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, excess=1]-[CO|PC=1,excess=0])
	test 1.treatment_imp#1.excess + 1.register_choice#1.treatment_imp#1.excess = 0 // not sig.
	margins excess#register_choice, dydx(treatment_imp)
	
* Specification (2)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.excess gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, excess=1]-[CO|PC=0,excess=0])
	test 1.treatment_imp#1.excess = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, excess=1]-[CO|PC=1,excess=0])
	test 1.treatment_imp#1.excess + 1.register_choice#1.treatment_imp#1.excess = 0 // not sig.
	margins excess#register_choice, dydx(treatment_imp)
	
*Specification (3)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.excess gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, excess=1]-[CO|PC=0,excess=0])
	test 1.treatment_imp#1.excess = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, excess=1]-[CO|PC=1,excess=0])
	test 1.treatment_imp#1.excess + 1.register_choice#1.treatment_imp#1.excess = 0 // not sig.
	margins excess#register_choice, dydx(treatment_imp)


* Group: chose an unhealthy snack 'today'

* Specification (1)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.excess i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, excess=1]-[CO|PC=0,excess=0])
	test 1.treatment_imp#1.excess = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, excess=1]-[CO|PC=1,excess=0])
	test 1.treatment_imp#1.excess + 1.register_choice#1.treatment_imp#1.excess = 0 // not sig.
	margins excess#register_choice, dydx(treatment_imp)
	
* Specification (2)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.excess gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, excess=1]-[CO|PC=0,excess=0])
	test 1.treatment_imp#1.excess = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, excess=1]-[CO|PC=1,excess=0])
	test 1.treatment_imp#1.excess + 1.register_choice#1.treatment_imp#1.excess = 0 // not sig.
	margins excess#register_choice, dydx(treatment_imp)
	
*Specification (3)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.excess gender wi_terc5 educ_curr mumlang_r2 participant_education_3 job_curr ///
	snacks_call5 drinks_call5 activecov5 confidence_future_bf choice_after_H choice_same i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, excess=1]-[CO|PC=0,excess=0])
	test 1.treatment_imp#1.excess = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, excess=1]-[CO|PC=1,excess=0])
	test 1.treatment_imp#1.excess + 1.register_choice#1.treatment_imp#1.excess = 0 // not sig.
	margins excess#register_choice, dydx(treatment_imp)

********************************************************************************
** Heterogeneity by health status (high_consumption) **
** Effect of Treatment: Cannot implement preferred option ** 
** (high consumption of salty snacks or sugary drinks versus 
** low consumption of salty snacks and sugary drinks) **

* Group: chose a healthy snack ex-ante

	estimates clear

* Specification (1)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.high_consumption i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, high consumption=1]-[CO|PC=0,high consumption=0])
	test 1.treatment_imp#1.high_consumption = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, high consumption=1]-[CO|PC=1,high consumption=0])
	test 1.treatment_imp#1.high_consumption + 1.register_choice#1.treatment_imp#1.high_consumption = 0 // not sig.
	margins high_consumption#register_choice, dydx(treatment_imp)
	
* Specification (2)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.high_consumption gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, high consumption=1]-[CO|PC=0,high consumption=0])
	test 1.treatment_imp#1.high_consumption = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, high consumption=1]-[CO|PC=1,high consumption=0])
	test 1.treatment_imp#1.high_consumption + 1.register_choice#1.treatment_imp#1.high_consumption = 0 // not sig.
	margins high_consumption#register_choice, dydx(treatment_imp)
	
*Specification (3)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.high_consumption gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess activecov5 confidence_future_bf choice_after_H choice_same i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, high consumption=1]-[CO|PC=0,high consumption=0])
	test 1.treatment_imp#1.high_consumption = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, high consumption=1]-[CO|PC=1,high consumption=0])
	test 1.treatment_imp#1.high_consumption + 1.register_choice#1.treatment_imp#1.high_consumption = 0 // not sig.
	margins high_consumption#register_choice, dydx(treatment_imp)


* Group: chose an unhealthy snack 'today'

* Specification (1)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.high_consumption i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, high consumption=1]-[CO|PC=0,high consumption=0])
	test 1.treatment_imp#1.high_consumption = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, high consumption=1]-[CO|PC=1,high consumption=0])
	test 1.treatment_imp#1.high_consumption + 1.register_choice#1.treatment_imp#1.high_consumption = 0 // not sig.
	margins high_consumption#register_choice, dydx(treatment_imp)
	
* Specification (2)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.high_consumption gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, high consumption=1]-[CO|PC=0,high consumption=0])
	test 1.treatment_imp#1.high_consumption = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, high consumption=1]-[CO|PC=1,high consumption=0])
	test 1.treatment_imp#1.high_consumption + 1.register_choice#1.treatment_imp#1.high_consumption = 0 // not sig.
	margins high_consumption#register_choice, dydx(treatment_imp)
	
*Specification (3)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.high_consumption gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess activecov5 confidence_future_bf choice_after_H choice_same i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, high consumption=1]-[CO|PC=0,high consumption=0])
	test 1.treatment_imp#1.high_consumption = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, high consumption=1]-[CO|PC=1,high consumption=0])
	test 1.treatment_imp#1.high_consumption + 1.register_choice#1.treatment_imp#1.high_consumption = 0 // not sig.
	margins high_consumption#register_choice, dydx(treatment_imp)
	
********************************************************************************
** Heterogeneity by health status (exercise_call5) **
** Effect of Treatment: Cannot implement preferred option ** 
** (physically active versus inactive) **

* Group: chose a healthy snack ex-ante

	estimates clear

* Specification (1)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.exercise_call5 i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, physically active=1]-[CO|PC=0,physically active=0])
	test 1.treatment_imp#1.exercise_call5 = 0 // sig.
	// beta 6 + beta 7 ([CO|PC=1, physically active=1]-[CO|PC=1,physically active=0])
	test 1.treatment_imp#1.exercise_call5 + 1.register_choice#1.treatment_imp#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#register_choice, dydx(treatment_imp)
	
* Specification (2)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.exercise_call5 gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, physically active=1]-[CO|PC=0,physically active=0])
	test 1.treatment_imp#1.exercise_call5 = 0 // sig.
	// beta 6 + beta 7 ([CO|PC=1, physically active=1]-[CO|PC=1,physically active=0])
	test 1.treatment_imp#1.exercise_call5 + 1.register_choice#1.treatment_imp#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#register_choice, dydx(treatment_imp)
	
*Specification (3)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.exercise_call5 gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess snacks_call5 drinks_call5 confidence_future_bf choice_after_H choice_same i.Site if choice_today==1, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, physically active=1]-[CO|PC=0,physically active=0])
	test 1.treatment_imp#1.exercise_call5 = 0 // sig.
	// beta 6 + beta 7 ([CO|PC=1, physically active=1]-[CO|PC=1,physically active=0])
	test 1.treatment_imp#1.exercise_call5 + 1.register_choice#1.treatment_imp#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#register_choice, dydx(treatment_imp)


* Group: chose an unhealthy snack 'today'

* Specification (1)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.exercise_call5 i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, physically active=1]-[CO|PC=0,physically active=0])
	test 1.treatment_imp#1.exercise_call5 = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, physically active=1]-[CO|PC=1,physically active=0])
	test 1.treatment_imp#1.exercise_call5 + 1.register_choice#1.treatment_imp#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#register_choice, dydx(treatment_imp)
	
* Specification (2)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.exercise_call5 gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, physically active=1]-[CO|PC=0,physically active=0])
	test 1.treatment_imp#1.exercise_call5 = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, physically active=1]-[CO|PC=1,physically active=0])
	test 1.treatment_imp#1.exercise_call5 + 1.register_choice#1.treatment_imp#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#register_choice, dydx(treatment_imp)
	
*Specification (3)
	eststo: reg snack_choice_H ib0.register_choice##ib0.treatment_imp##1.exercise_call5 gender wi_terc5 educ_curr job_curr mumlang_r2 participant_education_3 ///
	excess snacks_call5 drinks_call5 confidence_future_bf choice_after_H choice_same i.Site if choice_today==2, vce(cluster Site)
	matrix list e(b)
	// beta 6 ([CO|PC=0, physically active=1]-[CO|PC=0,physically active=0])
	test 1.treatment_imp#1.exercise_call5 = 0 // not sig.
	// beta 6 + beta 7 ([CO|PC=1, physically active=1]-[CO|PC=1,physically active=0])
	test 1.treatment_imp#1.exercise_call5 + 1.register_choice#1.treatment_imp#1.exercise_call5 = 0 // not sig.
	margins exercise_call5#register_choice, dydx(treatment_imp)
	
	
cap log close
