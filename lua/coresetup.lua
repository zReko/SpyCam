Hooks:PostHook(CoreSetup, "__render", "SpyCameraRenderViewports", function()
    if SpyCamera then
        SpyCamera:render()
    end
end)