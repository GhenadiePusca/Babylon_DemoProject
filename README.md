# Babylon_DemoProject
The demo project for Babylon Health

### High level requierements
  - When user opens the app a list of post titles should be shown, if available.
  - If user have no internet connection, the app should show the last cached posts.
  - If no internet connection and no cached posts, an empty page with the load button is displayed.
  - On interaction with the load button the posts load will be triggered.
  - On post selection a detail page will be shown containing the post title, body, author name and comments count.
  
### Detailed requierements
  - When user opens the app fetch the posts from the endpoint
  - Loaded data is validated and post items are created
  - Created post items are delivered to the main page
  
  - When user opens the app fetch the posts from the endpoint
  - Loaded data is validated and post items are created
  - Created post items are cached to the local storage
 
  - When user opens the app fetch the posts from the endpoint
  - If load failed, fetch from the local storage
  - Loaded data is validated and delivered to the main page
  
  - When user opens the app fetch the posts from the endpoint
  - If load failed, fetch from the local storage
  - If load from local storage fails, or no cached items, empty page with the load button is shown
  
  - Apps always tries to get the lastest data from the endpoint, if the retrieval fails,
    only then app will return the cached data
  
 ### High level tehnical analysys
   There are 4 main components to be developed:
      1. The remote with local cache fallback mechanism:
           - When asked for data fetches the data from the remote endpoint or from the local cache if remote fetch failed
           - Stores the feetched data to the local storage
      2. The UI component:
           - Shows the posts list and the detail for each post - layout, navigation
           - Defines the UI models for each screens.
      3. The repository:
           - Currently only one main repo, as the app is small.
           - Responsible for asking for the data the remote with local cache fallback mechanism
           - Applies any business logic over the received data and transforms to the apropriate models
             to be consumed by the UI component.
      4. The assembler:
           - Responsible for assembling all the components
           - Currently only one assembler as the app is small.
           
  ### Per Item tehnical details

  
