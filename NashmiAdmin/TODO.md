# TODO: Add Toggle for Video Source in Movies, Series, and Episode Forms

## Tasks
- [x] Add state variable `useVideoUrl` to toggle between video URL and embed code in movies form
- [x] Add radio buttons UI for selecting video source in movies form
- [x] Conditionally show video URL or embed code input field based on toggle in movies form
- [x] Update `_validateForm()` to require the selected field (video URL or embed code) in movies form
- [x] Ensure both fields are saved in `saveMovie()`
- [x] Add state variable `useVideoUrl` to toggle between video URL and embed code in series form
- [x] Add radio buttons UI for selecting video source in series form
- [x] Conditionally show video URL or embed code input field based on toggle in series form
- [x] Update `_validateForm()` to require the selected field (video URL or embed code) in series form
- [x] Ensure both fields are saved in `saveSeries()`
- [x] Add state variable `useVideoUrl` to toggle between video URL and embed code in episode edit form
- [x] Add radio buttons UI for selecting video source in episode edit form
- [x] Conditionally show video URL or embed code input field based on toggle in episode edit form
- [x] Update `_updateEpisode()` to require the selected field and clear unused field
- [x] Ensure both fields are saved in episode update
- [x] Add state variable `useVideoUrl` to toggle between video URL and embed code in episode add form
- [x] Add radio buttons UI for selecting video source in episode add form
- [x] Conditionally show video URL or embed code input field based on toggle in episode add form
- [x] Update `_saveEpisode()` to require the selected field and clear unused field
- [x] Ensure both fields are saved in episode add
- [x] Create SQL migration to add embed_code column to episodes table
- [x] Update schema documentation

## Followup Steps
- [x] Test the forms to ensure toggle works correctly
- [x] Verify validation for both options
- [x] Check that data is saved properly in database
