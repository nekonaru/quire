# Security Policy

## Reporting a Vulnerability

Please report security vulnerabilities privately through GitHub's private
vulnerability reporting on this repository, or by opening a security advisory
at https://github.com/nekonaru/quire/security/advisories/new.

Do not open a public issue for a suspected vulnerability.

Include the affected version, a description of the issue, and steps to
reproduce it. You can expect an acknowledgement within 7 days and a fix or a
mitigation plan within 30 days for confirmed issues.

## Scope

Quire builds static sites from your own Markdown files. It does not run a
server in production and it does not process untrusted input by design; the
main risks are malicious content in a site source (raw HTML in Markdown) and
dependency vulnerabilities, both of which are covered in the project's release
process.
