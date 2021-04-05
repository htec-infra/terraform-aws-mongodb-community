# <%= name %>

## Overview

<%= description %>

## Usage

```hcl
module "<%= name %>" {
  source = "git::ssh://"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)<% if (testFramework == '1') { %>
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)<% } -%>
<% if (testFramework == '2') { %>
- [ruby](https://rvm.io/)<% } %>

### Configurations

- Configure pre-commit hooks
```sh
pre-commit install
```

### Tests

- Tests are available in `test` directory
- In the test directory, run the below command
```sh
go test
```

## Authors

This project is authored by below people

- <%= author %>

