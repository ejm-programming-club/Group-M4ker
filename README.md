<div align="center">
    <img src="README_assets/icon.png"/>
    <br/>
    <a href="https://itunes.apple.com/us/app/group-m4ker/id1390259707">
        <img src="README_assets/download/ios_app_store.png"/>
    </a>
</div>

# Group M4ker
Group maker for IB's Group 4 field trips.

<div align="inline-block">
    <img src="README_assets/screenshots/launch_image.png">
    <img src="README_assets/screenshots/home_page.png">
</div>
<div align="inline-block">
    <img src="README_assets/screenshots/gdrive_import.png">
    <img src="README_assets/screenshots/class_editor.png">
</div>
<div align="inline-block">
    <img src="README_assets/screenshots/groups.png">
    <img src="README_assets/icon.png" height="480" width="480">
</div>


## Architecture
- [<img alt="Flutter" width="32" height="32" src="https://flutter.io/images/flutter-mark-square-100.png">](https://flutter.io)
- [<img alt="Google Drive APIs" width="32" height="32" src="https://www.gstatic.com/images/icons/material/product/2x/drive_32dp.png">](https://developers.google.com/drive/)

## Documentation
The code of the app is separated into `backend/` and `frontend/`,
where the former is responsible for the representation and generation of data
and the latter takes charge the user interface.

### Backend
> `backend/utils.dart`

A student's `Profile` keeps track of the student's
- gender: `Gender.M` | `Gender.F`
- leadership: `true` | `false`
- **bio**logy level: `null` (if this subject is not taken) | `Level.SL` | `Level.HL`
- **ch**e**m**istry level: `null` | `Level.SL` | `Level.HL`
- **phy**sics level: `null` | `Level.SL` | `Level.HL`

A `Student` is defined by his/her `String` name and `Profile` profile.

The list of all `Student`s is represented by a `Promo`
(as in **promo**tion, French for class;
 used instead of 'class' to avoid confusion with OOP).
`Promo` can be converted into and from csv files.

A `Promo` can be divided into `Group`s of `Student`s.
Such `Group`s form a `Grouping`.

> `backend/generator.dart`  
> `backend/generators/`

A `Generator` generates `Grouping`s.

A specific implementation of the `Generator` interface is `MinJealousyGenerator`,
which generates `Grouping`s on the basis of the minimisation of the differences (jealousy) between `Group`s.
 
> `backend/evaluator.dart`  
> `backend/evaluators/`

An `Evaluator` evaluates the quality of the `Grouping`s in terms of its issues.

A specific implementation of the `Evaluator` interface is the `MeanEvaluator`,
which evaluates `Grouping`s asserting that, for instance, the number of 
females, SLs and physicists do not deviate from the mean values.

### Frontend
- The global app state is managed within `Grouper`.
- The rendering of the groups and students are implemented in `GroupBox` and `StudentEntry`.
-  
