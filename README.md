# TestingCodeWorkshop

This repository shows how to run MATLAB tests using GitHub Actions

| **CI Platform** | **Badges** | **Badge Help** |
|:----------------|:-----------|:---------------|
| GitHub Actions | [![MATLAB](https://github.com/ebenetce/TestingCodeWorkshop/workflows/MATLAB/badge.svg)](https://github.com/ebenetce/TestingCodeWorkshop/actions/workflows/ci.yml/badge.svg) | [GitHub Actions documentation for setting up badges](https://docs.github.com/en/actions/managing-workflow-runs/adding-a-workflow-status-badge) |
| GitHub Actions | [![example branch parameter](https://github.com/ebenetce/TestingCodeWorkshop/workflows/MATLAB/badge.svg)(https://github.com/ebenetce/TestingCodeWorkshop/actions/workflows/ci.yml/badge.svg?branch=myFirstBranch) |


## Quick start guide
Here's how to really quickly and easily use this repository:
1. Fork the repository to your own GitHub account
2. Replace the MATLAB code and tests (in /main and /test) in your repository with your own MATLAB code and tests
3. Use the included CI configurations (Azure DevOps, CircleCI, GitHub Actions, or Travis CI) to set up your CI job and point it at your repository
4. Enjoy using CI with MATLAB!

That's really it!

There's no need to change any of the CI configuration files because they are all completely agnostic of the specific MATLAB code being used.
