---
title: "FERPA Student Records Redaction"
slug: "ferpa-student-records"
category: "education"
tags: ["FERPA", "education", "K-12", "higher-ed", "student records", "20 USC 1232g"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Remove personally identifiable information from student educational records per FERPA (20 USC 1232g; 34 CFR Part 99)."
entities: ["STUDENT", "DATE", "SSN", "PHONE", "EMAIL", "ADDRESS", "STUDENT_ID", "LUNCH_ID"]
exampleInput: "Student Sarah Johnson (SID 887623, born 2008-09-15) earned a B+ in Algebra II during Spring 2025. Contact parent at jjohnson@example.com or (555) 867-5309."
exampleOutput: "Student [STUDENT] ([REDACTED-SID], born [REDACTED-DATE]) earned a B+ in Algebra II during Spring 2025. Contact parent at [REDACTED-EMAIL] or [REDACTED-PHONE]."
---

## What this policy does

Redacts personally identifiable information from student educational records as defined by the [Family Educational Rights and Privacy Act (FERPA)](https://studentprivacy.ed.gov/ferpa) &mdash; the federal law governing disclosure of student records by schools that receive federal funding.

This policy targets the **PII fields** that identify a specific student:

- **Student names** &mdash; redacted to `[STUDENT]` (confidence-gated to avoid misfires on school names, building names, and common nouns)
- **Birthdates** &mdash; fully redacted when the date appears in a birth-related context
- **SSNs** &mdash; fully redacted (rare in modern student records but still appears in older systems and financial-aid forms)
- **Phone, email, address** &mdash; redacted (student or parent contact information)
- **Student IDs** &mdash; redacted with a custom identifier pattern (default matches `SID 887623`, `Student-ID: 887623`, etc.)
- **Lunch/meal program IDs** &mdash; redacted (these are educational-record-linked identifiers under FERPA)

It **preserves** the educational substance: grades, course names, term/semester references, narrative observations, attendance summaries. Those are the records' actual content; you usually want them for the analytical or operational purpose the redacted records are being used for.

## When to use this

- **Sharing data with external evaluators or researchers** (school districts running effectiveness studies with university partners)
- **Inter-district transfers** of de-identified cohort data for benchmarking
- **Reporting to state education agencies** where the requested record doesn't need to be student-linkable
- **EdTech vendor data sharing** under written consent or under FERPA's school-official exception
- **Internal analytics across schools** where the analytics team shouldn't have access to identified records

## When to customize

- **Directory information.** FERPA permits schools to disclose certain "directory information" (typically name, address, phone, dates of attendance, photographs, awards, participation in officially recognized activities) without consent &mdash; provided parents/students have been notified annually and given the opportunity to opt out. If you've collected directory-information opt-outs and want a less-aggressive variant for the opt-in records, remove the `personsName` and `address` entries (or build a parallel `ferpa-directory-allowed.json` policy).
- **Student ID format.** The default regex matches `SID 887623`, `Student ID: 887623` with 6+ digits. Replace with your district's actual format (state IDs, federal IDs, or proprietary SIS identifiers).
- **Confidence threshold.** `> 60` for names is moderate. School records have many proper nouns (school names, building names, district names, sports teams) that Philter can occasionally misclassify as personal names. Raise to `> 75` if you see false positives.
- **Parent/guardian names.** Not separately tagged &mdash; they get caught by `personsName` like any other name. If your use case treats parent contact info differently (e.g., emergency outreach preserved, marketing redacted), build a custom variant.
- **Special-education and IEP records.** These often contain additional sensitive content (disability diagnoses, medical history, behavioral observations) that go beyond standard FERPA PII. Pair this policy with a healthcare/PHI policy when redacting IEP narratives.

## Compliance notes

- FERPA applies to **schools that receive funding under any program administered by the U.S. Department of Education** &mdash; K-12 public schools, charter schools, post-secondary institutions, and certain private schools.
- "Educational records" are interpreted broadly: grades, transcripts, disciplinary records, counseling notes, special-education records, financial-aid records, attendance, and most narrative records maintained by school officials.
- Schools must obtain **written consent** from parents (or the student, once age 18 or attending post-secondary) before disclosing PII from educational records &mdash; subject to specific exceptions (school officials with legitimate educational interest, other schools the student is transferring to, audit/evaluation, etc.).
- This policy redacts PII fields, but does **not** by itself constitute de-identification under FERPA's standards (34 CFR 99.31(b)). True de-identification under FERPA requires a "reasonable determination" that a student's identity is not personally identifiable, considering all available information. Statistical evaluation is recommended for records shared as de-identified.
- State laws (e.g., the California Student Online Personal Information Protection Act &mdash; SOPIPA) may impose additional or stricter requirements. This policy is FERPA-baseline.

## References

- [20 USC § 1232g &mdash; FERPA](https://www.law.cornell.edu/uscode/text/20/1232g)
- [34 CFR Part 99 &mdash; FERPA implementing regulations](https://www.ecfr.gov/current/title-34/subtitle-A/part-99)
- [U.S. Department of Education FERPA overview](https://studentprivacy.ed.gov/ferpa)
- [Privacy Technical Assistance Center (PTAC) de-identification guidance](https://studentprivacy.ed.gov/resources/data-de-identification-overview-basic-terms)
