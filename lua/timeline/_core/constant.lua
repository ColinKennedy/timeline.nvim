local M = {}


M.BUFFER_RECORDS_VARIABLE = "_timeline_records"
M.RecordTypes = {
    file_save = "file_save",
    git_commit = "git_commit",
}
M.SourceTypes = {
    file = "file",
    git = "git",
}
M.VIEWER_FILE_TYPE = "timeline_viewer"


return M
