# Version 1.0.0
UNAME_S := $(shell uname -s)

runParticles: 
	swift run -c release Particles

runAsteroids: 
	swift run -c release Asteroids

# Lint
lint:
	swiftlint autocorrect --format
	swiftlint lint --quiet

lintErrorOnly:
	@swiftlint autocorrect --format --quiet
	@swiftlint lint --quiet | grep error

# Test links in README
# requires <https://github.com/tcort/markdown-link-check>
testReadme:
	markdown-link-check -p -v ./README.md

# lines of code
loc: clean
	find . -name "*.swift" -print0 | xargs -0 wc -l
