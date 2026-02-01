# F15: People (PRM)

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F15 |
| Priority | Phase 4 (Integration) |
| Dependencies | F1, F4, F5, F6 |
| Dependents | None |

## Purpose

Minimal Personal Relationship Management—maintain context about people you interact with. When you have a meeting with someone, Claude surfaces relevant background. When you mention someone, Claude links to their file.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F15.1 | One file per person in 8_People/ | Must |
| F15.2 | Frontmatter: name, email, company, role, areas, last_contact | Must |
| F15.3 | Body contains context notes and interaction log | Must |
| F15.4 | Morning brief links attendees to People files | Must |
| F15.5 | `last_contact` updated when interactions logged | Must |
| F15.6 | `/people <name>` surfaces person's context | Must |
| F15.7 | Offer to create person file when unknown contact appears | Should |

---

## File Structure

### Location

```
8_People/
├── jane-smith.md
├── john-doe.md
└── maria-garcia.md
```

### Filename Convention

```
{first-name}-{last-name}.md

Examples:
- jane-smith.md
- john-doe.md
- maria-garcia.md
```

Lowercase, hyphenated. Handles duplicates with disambiguation:
- `john-doe.md`
- `john-doe-verisign.md`

---

## Person File Template

```markdown
---
type: person
name: "Jane Smith"
email: "jane@verisign.com"
company: "Verisign"
role: "Partner Manager"
areas:
  - "[[domaison]]"
  - "[[jetpack]]"
last_contact: 2025-01-28
created: 2024-08-15T11:00:00+01:00
updated: 2025-01-28T16:00:00+01:00
---

## Context

Met at WordCamp 2024 in Portland. Primary contact for registry 
negotiations and bulk pricing discussions.

Prefers email over Slack for important decisions. Usually responds 
within 24 hours.

## Notes

- Has budget authority up to $50k
- Reports to VP of Partnerships
- Interested in expanding beyond .com

## Interactions

### 2025-01-28
1:1 meeting — Followed up on bulk discount proposal. She's taking it 
to leadership next week. [[2025-01-28 Tuesday]]

### 2025-01-15
Slack thread — Discussed Q1 transfer pricing targets. Concerns about 
competitor pricing. [[2025-01-15 Wednesday]]

### 2024-11-20
Initial meeting — Introduction via WordCamp. Exchanged contact info, 
agreed to explore partnership opportunities.
```

---

## Frontmatter Schema

```yaml
---
type: person
name: "Full Display Name"
email: "email@example.com"
company: "Company Name"
role: "Job Title or Relationship"
areas:
  - "[[area-link]]"
last_contact: 2025-01-28
created: timestamp
updated: timestamp
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| type | string | Yes | Always "person" |
| name | string | Yes | Full display name |
| email | string | No | Primary email address |
| company | string | No | Organization |
| role | string | No | Job title or relationship |
| areas | list | No | Work areas they relate to |
| last_contact | date | No | Most recent interaction |
| created | timestamp | Yes | When file was created |
| updated | timestamp | Yes | Last modification |

---

## Morning Brief Integration

When calendar events include attendees:

```markdown
### Calendar

- 10:00 Weekly standup (Domain team)
- 14:00 1:1 with [[Jane Smith]]
  - Company: Verisign
  - Last contact: January 28
  - Context: Discussed bulk discount proposal, waiting on leadership
```

### Matching Logic

1. Extract attendee email from calendar event
2. Search `8_People/` for matching `email` field
3. If found, link and surface context
4. If not found, note as "Unknown contact"

---

## Unknown Contact Handling

When an unknown person appears:

```
CALENDAR: 1:1 with sarah@newcompany.com

This person isn't in your People folder.

Would you like to create a file?
  [y] Yes, create sarah-unknown.md
  [n] No, skip
  [l] Later (remind me after meeting)

> y

Creating person file...

What's their full name?
> Sarah Johnson

What company are they from?
> NewCompany Inc

What's their role?
> Sales Director

Any areas they relate to?
> 

Created: 8_People/sarah-johnson.md
```

---

## `/people` Command

### Query by Name

```
/people jane

JANE SMITH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Company: Verisign
Role: Partner Manager
Email: jane@verisign.com
Areas: Domaison, Jetpack
Last Contact: January 28, 2025 (3 days ago)

CONTEXT
Met at WordCamp 2024. Primary contact for registry negotiations.
Prefers email over Slack.

RECENT INTERACTIONS
• Jan 28: 1:1 — Bulk discount proposal followup
• Jan 15: Slack — Q1 transfer pricing discussion

UPCOMING
• No scheduled meetings

Open file in Obsidian? [y/n]
```

### Query by Email

```
/people jane@verisign.com

[Same output as above]
```

### Multiple Matches

```
/people john

Found 2 people matching "john":

1. John Doe (Automattic) — Engineering
   Last contact: January 20

2. John Smith (Verisign) — Legal
   Last contact: December 15

Which one? [1/2/c to cancel]
```

---

## Interaction Logging

### Automatic

When processing captures that mention people:

```
INBOX ITEM: Slack thread with @jane

This thread includes Jane Smith (Verisign).

Update her last_contact to today? [Y/n]
> y

Add to her interaction log? [Y/n]
> y

Summary of interaction:
> Discussed Q1 pricing concerns

✓ Jane Smith updated
  last_contact: 2025-01-31
  Interaction logged
```

### Manual

```
/people jane --log

Adding interaction for Jane Smith.

Date (default: today):
> 

Type:
  [m] Meeting
  [e] Email
  [s] Slack
  [c] Call
  [o] Other
> m

Summary:
> Quarterly review, discussed 2025 roadmap

✓ Interaction logged
```

---

## Evening Review Integration

During review, when processing items involving people:

```
ITEM: Email from jane@verisign.com

Subject: RE: Bulk Pricing Proposal
Content: "Leadership approved! Let's schedule a call..."

This is from Jane Smith (Verisign).
Last logged interaction: January 28

Actions:
  [f] File email and update last_contact
  [l] Also add to interaction log
  [p] Open Jane's people file
  [s] Skip
```

---

## Weekly Review Integration

Optional people check:

```
PEOPLE CHECK (Optional)

People you haven't contacted in 30+ days:

1. John Doe (Automattic)
   Last contact: December 15 (47 days)
   Areas: Jetpack

2. Maria Garcia (Partner)
   Last contact: December 20 (42 days)
   Areas: Domaison

Would you like to:
  [r] Create reminder to reach out
  [n] Note for later
  [s] Skip this check
```

---

## Search and Discovery

### By Area

```
/people --area domaison

PEOPLE IN DOMAISON

• Jane Smith (Verisign) — Partner Manager
  Last contact: 3 days ago
  
• Maria Garcia (Partner) — Account Executive
  Last contact: 42 days ago ⚠
  
• Tom Wilson (Internal) — Product Lead
  Last contact: 1 day ago
```

### By Recency

```
/people --recent

RECENT CONTACTS (Last 7 Days)

• Jane Smith — Jan 28 (1:1 meeting)
• Tom Wilson — Jan 30 (Slack)
• Alex Chen — Jan 31 (Email)
```

### By Staleness

```
/people --stale 30

NOT CONTACTED IN 30+ DAYS

• John Doe — 47 days
• Maria Garcia — 42 days
• Chris Lee — 35 days
```

---

## Validation

| Check | Expected |
|-------|----------|
| Person files have required fields | ✓ |
| Calendar attendees matched | ✓ |
| Unknown contacts prompt creation | ✓ |
| /people command works | ✓ |
| last_contact updates | ✓ |
| Interaction logging works | ✓ |
| Area filtering works | ✓ |

---

## Related Features

- **F4 (Frontmatter)**: Person schema definition
- **F5 (Morning Brief)**: Surfaces people context
- **F6 (Evening Review)**: Updates people data
- **F7 (Weekly Review)**: Optional people check
- **F10 (Calendar)**: Source of attendee data
