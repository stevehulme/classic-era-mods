-- the toolbar is always visible and always one row of buttons

local _,t = ...
t.toolbar = CreateFrame("Frame",nil,t.main)

t.init:Register("toolbar")

function t.toolbar:Init()
    t.toolbar:SetPoint("TOPLEFT",6,-6)
    t.toolbar:SetPoint("TOPRIGHT",-6,-6)
    t.toolbar:SetHeight(t.constants.BUTTON_SIZE_NORMAL)

    -- buttons on right: Settings, Bookmark, Close
    t.toolbar.closeButton = t.buttons:Create(t.toolbar,24,24,2,1,TinyPad.Toggle,{anchorPoint="RIGHT",relativeTo=t.toolbar,relativePoint="RIGHT"},"Close","TinyPad version "..GetAddOnMetadata("TinyPad","Version"))
    t.toolbar.bookmarkButton = t.buttons:Create(t.toolbar,24,24,0,4,t.toolbar.BookmarkButtonOnClick,{anchorPoint="RIGHT",relativeTo=t.toolbar.closeButton,relativePoint="LEFT",xoff=-1,yoff=0},"Bookmarks","Go to a bookmarked page or manage bookmarks.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to keep bookmarks open until closed with this button.")
    t.toolbar.settingsButton = t.buttons:Create(t.toolbar,24,24,6,0,t.toolbar.SettingsButtonOnClick,{anchorPoint="RIGHT",relativeTo=t.toolbar.bookmarkButton,relativePoint="LEFT",xoff=-1,yoff=0},"Options","Search pages for text, change font and other options.")
    t.toolbar.searchButton = t.buttons:Create(t.toolbar,24,24,4,0,t.toolbar.SearchButtonOnClick,{anchorPoint="RIGHT",relativeTo=t.toolbar.settingsButton,relativePoint="LEFT",xoff=-1,yoff=0},"Search","Search pages for text.")

    -- buttons on left: New, Delete, Run
    t.toolbar.newButton = t.buttons:Create(t.toolbar,24,24,0,0,t.toolbar.NewPageButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar,relativePoint="LEFT"},"New","Add a new page after the last page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to insert the new page after the current page.")
    t.toolbar.deleteButton = t.buttons:Create(t.toolbar,24,24,2,0,t.toolbar.DeletePageButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar.newButton,relativePoint="RIGHT",xoff=1,yoff=0},"Delete","Permanently delete this page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to delete this page without confirmation.")
    t.toolbar.runButton = t.buttons:Create(t.toolbar,24,24,0,1,t.toolbar.RunPageButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar.deleteButton,relativePoint="RIGHT",xoff=1,yoff=0},"Run","Run this page as a Lua script.")
    t.toolbar.undoButton = t.buttons:Create(t.toolbar,24,24,2,4,t.toolbar.UndoButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar.runButton,relativePoint="RIGHT",xoff=1,yoff=0},"Undo","Revert changes made since opening this page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Ctrl+Z will also perform an Undo.\nHold Shift to revert all changes made.")
    t.toolbar.redoButton = t.buttons:Create(t.toolbar,24,24,2,5,t.toolbar.RedoButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar.undoButton,relativePoint="RIGHT",xoff=1,yoff=0},"Redo","Restore undos made since opening this page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Ctrl+Y will also perform a Redo.\nHold Shift to restore all undos.")


    -- buttons in middle: FirstPage, PrevPage, NextPage, LastPage
    t.toolbar.prevPageButton = t.buttons:Create(t.toolbar,24,24,0,3,t.toolbar.PrevPageButtonOnClick,{anchorPoint="RIGHT",relativeTo=t.toolbar,relativePoint="CENTER",xoff=-19+24,yoff=0},"Previous Page","Go to the previous page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to move this page back one page.")
    t.toolbar.nextPageButton = t.buttons:Create(t.toolbar,24,24,2,2,t.toolbar.NextPageButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar,relativePoint="CENTER",xoff=19+24,yoff=0},"Next Page","Go to the next page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to move this page forward one page.")
    t.toolbar.firstPageButton = t.buttons:Create(t.toolbar,16,24,2,3,t.toolbar.FirstPageButtonOnClick,{anchorPoint="RIGHT",relativeTo=t.toolbar.prevPageButton,relativePoint="LEFT",xoff=-1,yoff=0},"First Page","Go to the first page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to move this page to the first page.")
    t.toolbar.lastPageButton = t.buttons:Create(t.toolbar,16,24,2,3,t.toolbar.LastPageButtonOnClick,{anchorPoint="LEFT",relativeTo=t.toolbar.nextPageButton,relativePoint="RIGHT",xoff=1,yoff=0},"Last Page","Go to the last page.\n\n"..t.constants.TOOLTIP_SUBTEXT_COLOR.."Hold Shift to move this page to the last page.")

    -- PageNumber in middle
    t.toolbar.pageNumber = t.toolbar:CreateFontString(nil,"ARTWORK","GameFontHighlight")
    t.toolbar.pageNumber:SetPoint("CENTER",t.toolbar,"CENTER",25-13,0)
end

function t.toolbar:Resize(width,height)
    local navButtonSpacing = width >= t.constants.MIN_WIDTH_FOR_PAGE_NUM and 19 or 1 -- space PrevPageButton and NextPageButton apart when page number is shown
    local buttonSize = width >= t.constants.MIN_WIDTH_FOR_NORMAL_BUTTONS and t.constants.BUTTON_SIZE_NORMAL or t.constants.BUTTON_SIZE_SMALL

    local showPageNumber = width >= t.constants.MIN_WIDTH_FOR_PAGE_NUM
    local showRedoButton = width >= t.constants.MIN_WIDTH_FOR_REDO_BUTTON
    local showUndoButton = width >= t.constants.MIN_WIDTH_FOR_UNDO_BUTTON
    local showSearchButton = width >= t.constants.MIN_WIDTH_FOR_SEARCH_BUTTON

    t.toolbar.pageNumber:SetShown(showPageNumber)
    t.toolbar.redoButton:SetShown(showRedoButton)
    t.toolbar.undoButton:SetShown(showUndoButton)
    t.toolbar.searchButton:SetShown(showSearchButton)

    local numLeftButtons = 3+(showUndoButton and 1 or 0)+(showRedoButton and 1 or 0)
    local numRightButtons = 3+(showSearchButton and 1 or 0)

    local centerOffset = (numLeftButtons-numRightButtons)*buttonSize/2
    t.toolbar.prevPageButton:SetPoint("RIGHT",t.toolbar,"CENTER",centerOffset-navButtonSpacing,0)
    t.toolbar.nextPageButton:SetPoint("LEFT",t.toolbar,"CENTER",centerOffset+navButtonSpacing,0)

    for _,button in ipairs(t.toolbar.allButtons) do
        if button==t.toolbar.firstPageButton or button==t.toolbar.lastPageButton then
            button:SetSize(buttonSize-8,buttonSize)
        else
            button:SetSize(buttonSize,buttonSize)
        end
    end

    t.toolbar:SetHeight(buttonSize)
end

-- called during layout changes; updates the state of buttons
function t.toolbar:Update()
    t.buttons:SetEnabled(t.toolbar.firstPageButton,not t.pages:IsAtFirstPage())
    t.buttons:SetEnabled(t.toolbar.prevPageButton,not t.pages:IsAtFirstPage())
    t.buttons:SetEnabled(t.toolbar.nextPageButton,not t.pages:IsAtLastPage())
    t.buttons:SetEnabled(t.toolbar.lastPageButton,not t.pages:IsAtLastPage())
    t.toolbar.pageNumber:SetText(t.pages:GetCurrentPageNum())
    t.toolbar:UpdateUndoRedoButtonState()
end

-- also called from editor when text changes
function t.toolbar:UpdateUndoRedoButtonState()
    t.buttons:SetEnabled(t.toolbar.undoButton,t.editor:CanUndo())
    t.buttons:SetEnabled(t.toolbar.redoButton,t.editor:CanRedo())
end

--[[ button onclicks ]]

function t.toolbar:SettingsButtonOnClick()
    t.settings:Toggle()
end

function t.toolbar:SearchButtonOnClick()
    t.searchbar:Toggle()
end

function t.toolbar:BookmarkButtonOnClick()
    if t.layout.currentLayout=="bookmarks" then
        t.settings.saved.PinBookmarks = false
    elseif IsShiftKeyDown() then
        t.settings.saved.PinBookmarks = true
    end
    t.bookmarks:Toggle()
end

function t.toolbar:NewPageButtonOnClick()
    t.layout:Show("default") -- collapse anything that might be open
    if IsShiftKeyDown() then
        t.pages:GoToNewPage(t.pages:GetCurrentPageNum())
    else
        t.pages:GoToNewPage()
    end
    t.editor.editBox:SetFocus(true)
end

function t.toolbar:DeletePageButtonOnClick()
    -- if shift is down, or the page is empty, then delete without confirmation
    if IsShiftKeyDown() or t.editor.editBox:GetText():trim()=="" then
        t.pages:DeletePage(t.pages:GetCurrentPageNum())
    else
        if t.layout.currentLayout~="confirmbar" then -- if not already confirming a delete
            t.confirmbar:Confirm("Delete this page?",function() t.pages:DeletePage(t.pages:GetCurrentPageNum()) end)
        else
            t.layout:Hide("confirmbar")
        end
    end
end

function t.toolbar:RunPageButtonOnClick()
    t.pages:RunPage()
end

function t.toolbar:FirstPageButtonOnClick()
    local currentPageNum = t.pages:GetCurrentPageNum()
    if IsShiftKeyDown() and currentPageNum>1 then
        t.pages:SavePage() -- in case any edits are happening, save them before moving the page
        t.pages:MovePage(t.pages:GetCurrentPageNum(),1) -- move page to start
    end
    t.pages:GoToFirstPage(IsShiftKeyDown())
end

function t.toolbar:PrevPageButtonOnClick()
    local currentPageNum = t.pages:GetCurrentPageNum()
    if IsShiftKeyDown() and currentPageNum>1 then
        t.pages:SavePage()
        t.pages:SwapPages(currentPageNum,currentPageNum-1)
    end
    t.pages:GoToPrevPage(IsShiftKeyDown())
end

function t.toolbar:NextPageButtonOnClick()
    local currentPageNum = t.pages:GetCurrentPageNum()
    if IsShiftKeyDown() and currentPageNum<#t.pages.saved then
        t.pages:SavePage()
        t.pages:SwapPages(currentPageNum,currentPageNum+1)
    end
    t.pages:GoToNextPage(IsShiftKeyDown())
end

function t.toolbar:LastPageButtonOnClick()
    local currentPageNum = t.pages:GetCurrentPageNum()
    if IsShiftKeyDown() and currentPageNum<#t.pages.saved then
        t.pages:SavePage()
        t.pages:MovePage(t.pages:GetCurrentPageNum(),#t.pages.saved)
    end
    t.pages:GoToLastPage(IsShiftKeyDown())
end

function t.toolbar:UndoButtonOnClick()
    t.editor:Undo()
end

function t.toolbar:RedoButtonOnClick()
    t.editor:Redo()
end
