# v0.4.3 2023-03-22
- `Sentry-Error-Id`: Don't assume status code is an Integer

# v0.4.2 2022-12-19
- `Sentry-Error-Id`: Set `Access-Control-Expose-Headers` so frontend can access header

# v0.4.1 2022-11-18
- Rename header to `Sentry-Error-Id` for consistency

# v0.4.0 2022-11-14
- Add `SentryErrorID` middleware
- Drop support for Ruby 2.x

# v0.3.0 2022-05-30
- Support passing `with` to refinement
- Call ambiguity handler with resolved collection rather than original collection, to avoid logging huge values

# v0.1.15 2021-03-26
- Switched Rails dependency to ActiveRecord and ActiveSupport

# v0.1.14 2020-11-25
- Added `NxtSupport::DurationAttributeAccessor`

# v0.1.13 2020-11-13
- Fixed `Email::REGEXP` to be more generous about hostname

# v0.1.12 2020-11-11
- Added `bin/release` script to publish GitHub tags

# v0.1.11 2020-10-29

- Introduced `NxtSupport::Services::Base`

# v0.1.10 2020-10-10

- Introduced `NxtSupport::Enum`
- Deprecated `NxtSupport::EnumHash`


# v0.1.9 2020-09-09

- Fix `NxtSupport::PreprocessAttributes` to use new `nxt_registry 0.3.0` interface

# v0.1.8 2020-09-09

- Added `NxtSupport::BirthDate`

# v0.1.7 2020-08-20

- Added `NxtSupport::Crystalizer`

# v0.1.6 2020-06-18

- Added `NxtSupport::PreprocessAttributes`

# v0.1.5 2020-06-17

- Added `NxtSupport::AssignableValues`

# v0.1.3 2020-02-19

- Added `NxtSupport::IndifferentlyAccessibleJsonAttrs`
- Added `NxtSupport::HasTimeAttributes`.

# v0.1.2 2020-02-12

- Added `NxtSupport::Email`.

# v0.1.1 2020-02-04

### Added

- Added `NxtSupport::EnumHash`.

[Compare v0.1.0...v0.1.1](https://github.com/nxt-insurance/nxt_support/compare/v0.1.0...v0.1.1)

# v0.1.0 2019-09-29

Initial release.
