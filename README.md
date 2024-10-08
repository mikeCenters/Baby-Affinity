# Baby Affinity
A modern approach to baby naming.

#### Release:
- version 2.0.2

#### Development:
- version 2.0.3


## Overview

#### Choose Your Perfect Baby Name with Baby Affinity!

Selecting a baby name has never been more enjoyable! Baby Affinity transforms the name selection process into an exciting journey with its unique and fun approach. As you explore and choose names, our innovative Affinity Rating System tracks your preferences and assigns each name a personalized rating, helping you find the perfect name for your little one.

#### Why Baby Affinity?

Baby Affinity proudly introduces the first name rating system designed just for you. With a database of 2000 names and a sophisticated rating algorithm inspired by the ELO system, our app curates a personalized list of names based on your choices and preferences. No two lists are ever the same!

### Features:

- Affinity Rating System: Discover names that align with your tastes using our advanced rating algorithm.
- Share Names: Collaborate with a partner to find names you both love.
- Mark Favorite Names: Indicate which names are your favorite.
- 2000 Names: Access a diverse and ever-growing collection of names.
- Privacy: Your data is secure and protected within Apple’s ecosystem.
- In-App Support: Get immediate help and support directly within the app.
- Dark Mode Support: Enjoy a sleek, modern interface that’s easy on the eyes, even in low light.
- Reset Your Ratings: Start fresh whenever you want with the simple reset feature.

#### Uncover Unique Names Just for You!

Baby Affinity’s Affinity Rating System is more than just a tool; it’s your personal baby name expert. By analyzing your selections and preferences, it provides a tailor-made list of names, ensuring that your choice is as unique as your family.

Get ready to embark on a fun and exciting journey to find your baby’s perfect name with Baby Affinity. Download now and start discovering!


## ToDo:

- Favorite Animation - Expandable Names View is where the error begins. Subviews work.
- Search and Add Names
- Add Tags to create categories.
- Add precurated top names as a banner to add names to your favorites. These could be pulled from the global list as rising names or top 10 global names.
- Update the Unit Tests.


# Change Log:
## version 2.0.2:
- Migrated Store and SystemLogger to packages.
- Updated Views and other objects to utilize the Store and SystemLogger packages.
- Updated Views to use the `@ProductStatus` macro for monitoring status.
- Updated Codebase and previews.
- Updated algorithm that presents names.
    - Now, the user is forced to see all names once.
    - After all names have been seen, the algo presents:
        - -1 Standard Deviation: 1 name
        - +2 Standard Deviation: 2 names
        - Between -1 and +2 Standard Deviation: 7 names
- Updated Top Names View to refresh names on purchase state change to resolve unorganized loading when purchased.
- Updated App Icon to support Dark and Tinted modes.
- Fixed bug with name picking not loading 10 names when appearing.

## version 2.0.1:
- Fixed bug with Name Preview Card
    - Name Preview was not changing `Sex` when the user would change the property.

## version 2.0.0:
- App overhaul. It has been a few years and the entire codebase is updated to support new technologies.
- Added the ability to view names with a stored last name.
- Enhanced the feed to support multiple categories of names; Top Names, Favorite Names, etc.
- Added the ability to favorite names.
- Users can now share names with a partner to find shared top names and favorites.
- New App Icon

## version 1.0.2:
- Fixed a bug with the generator's bell curve formula.
- The mean was never properly setting.

## version 1.0.1:
- Updated the support links and app description.
- Website is available.

## version 1.0:
- Initial Release.
