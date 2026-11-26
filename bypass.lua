local logicCommonMsgBoxFn, cacheCPPAPIConfigFn, helperFn, tbl, helperFnRef, tblRef, logicCommonMsgBoxFnRef, helperFnVal, helperFnAlt, kismetSystemLibraryFn, helperFnSub, helperFnItem, helperFnCur, helperFnNext, helperFnAux, helperFnTmp, helperFnCtx, helperFnOpt, val, tblVal, helperFnExtra, helperFnEntry, helperFnLocal, screenshotMakerFn, tblAlt, helperFnCopy, helperFnPrev, helperFnData, helperFnInner, helperFnCache, valRef, valVal, key, entry, battleHUDUIBP

-- ═══════════════════════════════════════════════════════════════════════════
-- [1] UNIFIED LICENSE CHECK (تاريخ واحد + عرض التاريخ والوقت المتبقي)
-- ═══════════════════════════════════════════════════════════════════════════
local LicenseOk = false
do
  -- 📅 تاريخ الصلاحية (عدّل هنا فقط)
  local EXPIRE_YEAR, EXPIRE_MONTH, EXPIRE_DAY = 2026, 11, 25
  local EXPIRE_HOUR, EXPIRE_MIN, EXPIRE_SEC = 23, 59, 59

  local function checkBypassLicense()
    local val, time, loaded, helperFn
    val = os.time({year = EXPIRE_YEAR, month = EXPIRE_MONTH, day = EXPIRE_DAY, hour = EXPIRE_HOUR, min = EXPIRE_MIN, sec = EXPIRE_SEC})
    time = os.time()
    loaded = package.loaded
    helperFn = "client.slua.logic.common.logic_common_msg_box"
    loaded = loaded[helperFn] or require("client.slua.logic.common.logic_common_msg_box")

    -- 📆 تنسيق التاريخ
    local dateStr = string.format("%04d/%02d/%02d - %02d:%02d", EXPIRE_YEAR, EXPIRE_MONTH, EXPIRE_DAY, EXPIRE_HOUR, EXPIRE_MIN)

    if val < time then
      function helperFn()
        pcall(function()
          loaded.Show(4, "STATUS ALERT",
            " VIP BYPASS\n\n• STATUS: EXPIRED\n\n• انتهت الصلاحية في:\n" .. dateStr .. "\n\n• Contact: @MON5LA",
            function()
              helperFn()
            end)
        end)
      end
      helperFn()
      return false
    else
      if not _G.WelcomeShown then
        -- ⏳ حساب الوقت المتبقي
        local diff = val - time
        local days = math.floor(diff / 86400)
        local hours = math.floor((diff % 86400) / 3600)
        local mins = math.floor((diff % 3600) / 60)
        local remainingStr = string.format("%d يوم / %d ساعة / %d دقيقة", days, hours, mins)

        pcall(function()
          loaded.Show(4, "الحماية المدفوعه",
            "تم تفعيل الحماية ✅\n\n📅 تاريخ الانتهاء:\n" .. dateStr ..
            "\n\n⏳ الوقت المتبقي:\n" .. remainingStr ..
            "\n\n• العب بذكاء\n• لا تتخطي 10 كيل",
            function()
            end)
          _G.WelcomeShown = true
        end)
      end
      return true
    end
  end

  LicenseOk = checkBypassLicense()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [2] BYPASS HOOKS (من 1.lua - كاملة بدون تغيير)
-- ═══════════════════════════════════════════════════════════════════════════
do
  local function returnTrue() return true end
  local function returnFalse() return false end
  local function returnZero() return 0 end
  local function returnEmptyTable() return {} end
  local function returnNil() return nil end
  local function returnTrueAlt() return true end
  local function returnEmptyString() return "" end
  local function returnNoEmulator() return "NoEmulator" end

  local function safeRequire(arg, opt)
    local ok, res
    ok = type(arg)
    res = "string"
    if ok == res and arg ~= "" then
      if package.loaded[arg] ~= nil then
        return package.loaded[arg]
      end
      ok, res = pcall(require, arg)
      if ok and res ~= nil then
        return res
      end
    end
    ok = type(opt)
    if ok == "string" and opt ~= "" then
      ok = rawget(_G, opt)
      if ok ~= nil then
        return ok
      end
    end
    return nil
  end

  local function safeTableGet(arg, opt)
    local ok, res
    ok = type(arg)
    res = "table"
    if ok ~= res then
      ok = nil
      return ok
    end
    ok = type(arg.Get)
    res = "function"
    if ok ~= res then
      ok = nil
      return ok
    end
    ok, res = pcall(function()
      local val
      val = arg
      return val:Get(opt)
    end)
    if ok and res ~= nil then
      return res
    end
    return nil
  end

  local BLOCKED_REPORT_METHODS = {
    ReportAttackFlow = true,
    ReportSecAttackFlow = true,
    ReportFireArms = true,
    ReportVerifyInfoFlow = true,
    ReportMrpcsFlow = true,
    ReportPlayerBehavior = true,
    ReportTeammatHurt = true,
    ReportPlayerMoveRoute = true,
    ReportPlayerPosition = true,
    ReportSecVehicleMoveFlow = true,
    report_parachute_data = true,
    on_tss_sdk_anti_data = true,
    ReportAimFlow = true,
    ReportHitFlow = true,
    ReportCircleFlow = true,
    report_players_ping = true,
    report_player_ip = true,
    report_net_saturate = true,
    report_speed_hack = true,
    report_wall_hack = true,
    report_aim_bot = true,
    report_esp_usage = true,
    report_modded_files = true,
    detect_cheat = true,
    ban_player = true,
    client_anti_cheat_report = true,
    ClientSecMrpcsFlow = true,
    MrpcsData = true,
    CheckReportSecAttackFlow = true,
    CheckReportSecAttackFlowWithAttackFlow = true,
    RPC_ClientCoronaLab = true,
    CoronaLabReport = true,
    CoronaLabData = true,
    PlayerSecurityInfo = true,
    ReportSecurityInfo = true,
    SendSecurityData = true,
    ClientCircleFlow = true,
    IsEnableReportMrpcsInCircleFlow = true,
    IsEnableReportMrpcsInPartCircleFlow = true,
    bReportedModifierException = true,
    ReportModifierException = true,
    RPC_Server_ReportSimulateCharacterLocation = true,
    ReportSimulateCharacterLocation = true,
    RPC_Client_ShootVertifyRes = true,
    BulletHitInfoUploadData = true,
    ShootVerifyFailed = true,
    report_unrealnet_exception = true,
    tss_sdk_report = true,
    SwiftHawk = true,
    ClientSwiftHawk = true,
    ClientSwiftHawkWithParams = true,
    SwiftHawkReport = true,
    SwiftHawkData = true,
    AntiCheatReport = true,
    CheatDetection = true,
    ViolationReport = true,
    SecurityViolation = true,
    IntegrityCheck = true,
    SignatureVerify = true,
    offline_ban_check = true,
    online_ban_check = true,
    data_check_failed = true,
    request_account_ban_status = true,
    report_ban_status = true,
    check_offline_ban = true,
    sync_ban_penalty = true
  }

  local function hookNetUtilSendPacket()
    local mrmodSendPacketHooked, hookTarget
    mrmodSendPacketHooked = type(NetUtil)
    hookTarget = "table"
    if mrmodSendPacketHooked ~= hookTarget then
      return
    end
    mrmodSendPacketHooked = type(NetUtil.SendPacket)
    hookTarget = "function"
    if mrmodSendPacketHooked ~= hookTarget then
      return
    end
    mrmodSendPacketHooked = NetUtil._mrmodSendPacketHooked
    if mrmodSendPacketHooked then
      mrmodSendPacketHooked = NetUtil
      mrmodSendPacketHooked.IsBypassed = true
      return
    end
    mrmodSendPacketHooked = NetUtil.SendPacket
    hookTarget = NetUtil

    function hookTarget.SendPacket(arg, opt, ...)
      local val
      val = NetUtil
      val = opt or val
      if arg ~= val or not opt then
        val = arg
      end
      if type(val) == "string" then
        if BLOCKED_REPORT_METHODS[val] then
          return nil
        end
      end
      return mrmodSendPacketHooked(arg, opt, ...)
    end
    hookTarget = NetUtil
    hookTarget._mrmodSendPacketHooked = true
    hookTarget = NetUtil
    hookTarget.IsBypassed = true
  end

  local function hookTssManager()
    pcall(function()
      local tss, val, valRef, valVal, tbl, ok, res, key, entry, keyRef, entryRef, valAlt, helperFn
      if rawget(_G, "TssManager") then
        if type(_G.TssManager) == "table" then
          _G.TssManager.SendEigeninfoData = returnZero
          _G.TssManager.SaveSendEigeninfoCode = returnZero
          _G.TssManager.SendSkdData = returnTrue
          _G.TssManager.OnRecvData = returnTrue
        end
      end
      tss = rawget(_G, "Tss")
      if tss then
        tss = type(_G.Tss)
        if tss == "table" then
          tss = _G.Tss

          function tss.GetUserTag4Lua()
            return "clean"
          end
          _G.Tss.GetDeviceFeature = returnZero
          _G.Tss.EigenArrayObfuscationVerify = returnZero
          _G.Tss.SendEigeninfoData = returnZero
          _G.Tss.SendSkdData = returnTrue
        end
      end
      tss = type(NetUtil)
      if tss == "table" then
        tss = NetUtil
        tss.SendTss = returnTrue
        tss = NetUtil
        tss.OnTssRsp = returnTrue
        if NetUtil.NetUnstableReport then
          NetUtil.NetUnstableReport.Enabled = false
        end
      end
      tss = type(UnrealNet)
      if tss == "table" then
        tss = UnrealNet.FilterNetworkException
        if tss then
          tss = UnrealNet
          tss.FilterNetworkException = returnFalse
        end
      end
      tss = safeRequire("GameLua.Mod.BaseMod.Client.Security.Gokuba", "Gokuba")
      if type(tss) == "table" then
        if type(tss.ForwardFeature) == "function" then
          tss.ForwardFeature = returnNil
        end
      end
      val = safeRequire("client.slua.logic.crew.logic_crew_authentication", nil)
      if type(val) == "table" then
        if type(val.SetAuthCheckInfo) == "function" then
          pcall(function()
            val.SetAuthCheckInfo(true, 0)
          end)
        end
      end
      valRef = safeRequire("GameLua.Mod.BaseMod.Common.UI.RealTimeBan", "RealTimeBan")
      if type(valRef) == "table" then
        valRef.OnPlayerWithRealTimeBan = returnNil
        valRef.ShowAlias = returnNil
        valRef.OnSyncPlayerInfo = returnNil
      end
      valVal = safeRequire("GameLua.Mod.BaseMod.GamePlay.Spectator.CSpectatorComponent", "CSpectatorComponent")
      if type(valVal) == "table" then
        valVal.ServerRPC_HawkReportCheat = returnNil
        valVal.ServerRPC_RequestImprison = returnNil
        valVal.ServerRPC_SecReportReconcile = returnNil
        valVal.OnHawkBroadcast = returnNil
      end
      tbl = {
        GetApplicationVersion = true,
        GetAppVersion = true,
        ProjectSavedDir = true,
        ProjectContentDir = true,
        IsWindowOB = true,
        GetDevicePlatformName = true,
        GetPhoneType = true,
        GetMemorySize = true,
        GetPublishRegion = true,
        IsEmulator = true
      }
      ok, res = pcall(function()
        return require("client.slua.config.CacheCPPAPI.CacheCPPAPIConfig", nil, nil)
      end)
      if ok then
        if type(res) == "table" then
          for key, entry in pairs(res) do
            if type(entry) == "table" then
              if entry.LuaTableName then
                if type(_G[entry.LuaTableName]) == "table" then
                  if type(entry.CacheFunctions) == "table" then
                    for keyRef, entryRef in ipairs(entry.CacheFunctions) do
                      valAlt = tbl[entryRef]
                      if not valAlt then
                        valAlt = _G[entry.LuaTableName]

                        function helperFn(...)
                          local valSub, valItem
                          valSub = string.lower(tostring(entryRef))
                          valItem = valSub:find("crc")
                          if valItem then
                            return 0
                          end
                          valItem = valSub:find("hash")
                          if valItem then
                            return 0
                          end
                          return true
                        end

                        valAlt[entryRef] = helperFn
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end)
  end

  local function hookSluaLoader()
    pcall(function()
      local getSignature, val, attach, tableRef
      getSignature = slua
      if getSignature then
        getSignature = slua.getSignature
        if getSignature then
          getSignature = slua

          function getSignature.getSignature()
            return 3735928559
          end
        end
      end
      getSignature = safeRequire("slua.loader", "slua_loader")
      if type(getSignature) == "table" then
        getSignature.verifyBytecode = returnTrueAlt
        getSignature.checkIntegrity = returnTrueAlt
        if getSignature.disableSignatureCheck then
          getSignature.disableSignatureCheck = returnTrueAlt
        end
      end
      val = safeRequire("slua.serialize", nil)
      attach = type(val)
      tableRef = "table"
      if attach == tableRef then
        val.check = returnTrueAlt
        val.verify = returnTrueAlt
      end
      attach = jit
      if attach then
        attach = jit.attach
        if attach then
          attach = jit._mrmodBcAttached
          if not attach then
            jit.attach(function()

            end, "bc")
            attach = jit
            attach._mrmodBcAttached = true
          end
        end
      end
      if _G.slua_verify then
        _G.slua_verify = returnTrueAlt
      end
      if _G.check_slua_integrity then
        _G.check_slua_integrity = returnTrueAlt
      end
    end)
  end

  local function hookPakSignatureCheck()
    pcall(function()
      local kismetSystemLibrary, creativeModeBlueprintLibrary, strVal, val
      local sTExtraBlueprintFunctionLibrary
      kismetSystemLibrary = type(import)
      creativeModeBlueprintLibrary = "function"
      if kismetSystemLibrary == creativeModeBlueprintLibrary then
        kismetSystemLibrary = import("KismetSystemLibrary")
      else
      end
      if kismetSystemLibrary then
        kismetSystemLibrary.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
        kismetSystemLibrary.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
        kismetSystemLibrary.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
        kismetSystemLibrary.ExecuteConsoleCommand(nil, "sig.Check 0")
        kismetSystemLibrary.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
      end
      creativeModeBlueprintLibrary = type(import)
      strVal = "function"
      if creativeModeBlueprintLibrary == strVal then
        creativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
      else
      end
      if creativeModeBlueprintLibrary then
        function creativeModeBlueprintLibrary.MD5HashByteArray()

          return "00000000000000000000000000000000"
        end

        function creativeModeBlueprintLibrary.MD5HashFile()
          return "00000000000000000000000000000000"
        end

        function creativeModeBlueprintLibrary.GetContentDiffData()
          return true, "BYPASSED", nil, nil
        end
        creativeModeBlueprintLibrary.VerifyFileIntegrity = returnTrueAlt
      end
      strVal = _G.MD5Hash
      if strVal then
        strVal = _G

        function strVal.MD5Hash()
          return "00000000000000000000000000000000"
        end
      end
      strVal = _G.CRC32
      if strVal then
        strVal = _G

        function strVal.CRC32()
          return 0
        end
      end
      strVal = _G.SHA1
      if strVal then
        strVal = _G

        function strVal.SHA1()
          return "BYPASS"
        end
      end
      strVal = safeRequire("common.file_hash_checker", nil)
      if type(strVal) == "table" then
        strVal.CheckFileMD5 = returnTrueAlt
        strVal.VerifyAll = returnTrueAlt

        function strVal.GetHash()
          return "BYPASS"
        end
      end
      val = safeRequire("TssSdk", "TssSdk")
      if type(val) == "table" then
        function val.GetFileMD5()

          return "BYPASS"
        end
        val.VerifyFileSignature = returnTrueAlt
      end
      sTExtraBlueprintFunctionLibrary = type(import)
      if sTExtraBlueprintFunctionLibrary == "function" then
        sTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      else
      end
      if sTExtraBlueprintFunctionLibrary then
        sTExtraBlueprintFunctionLibrary.CheckMD5 = returnTrueAlt

        function sTExtraBlueprintFunctionLibrary.GetMD5()
          return "BYPASS"
        end
        sTExtraBlueprintFunctionLibrary.VerifyFile = returnTrueAlt
      end
    end)
  end

  local function hookPufferTlogAndAvatar()
    pcall(function()
      local val, valRef, valVal, valAlt
      val = safeRequire("client.slua.logic.download.report.puffer_tlog", nil)
      if type(val) == "table" then
        val.ReportEvent = returnTrue
        val.ReportDownloadResult = returnTrue
        val.ReportODPTDError = returnTrue
        val.ReportSkinError = returnTrue
      end
      valRef = safeRequire("AvatarUtils", "AvatarUtils")
      if type(valRef) == "table" then
        valRef.CheckIsWeaponInBlackList = returnFalse
        valRef.IsValidAvatar = returnTrueAlt
        valRef.CheckAvatarIntegrity = returnTrueAlt
        valRef.ReportInvalidAvatar = returnTrue
      end
      valVal = safeTableGet(safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr", nil), "FileCheckSubsystem")
      if type(valVal) == "table" then
        valVal.StartCheck = returnTrue
        valVal.ReportAbnormalFile = returnTrue
        valVal.StopCheck = returnTrue
      end
      valAlt = safeRequire("client.slua.logic.report.EquipmentExceptionReport", nil)
      if type(valAlt) == "table" then
        valAlt.Report = returnTrue
        valAlt.SendException = returnTrue
      end
    end)
  end

  local function hookScreenshotTLog()
    pcall(function()
      local screenshotMTDer, strVal, val, valRef, valVal, valAlt, tbl, firebase, key, valSub
      local facebookAnalytics
      screenshotMTDer = type(import)
      strVal = "function"
      if screenshotMTDer == strVal then
        screenshotMTDer = import("ScreenshotMTDer")
      else
      end
      if screenshotMTDer then
        function screenshotMTDer.MTDePicture()

          return ""
        end

        function screenshotMTDer.ReMTDePicture()
          return ""
        end
        screenshotMTDer.HasCaptured = returnTrueAlt
        screenshotMTDer.TakeScreenshot = returnTrue
      end
      strVal = safeRequire("TLog", "TLog")
      if type(strVal) == "table" then
        strVal.Info = returnTrue
        strVal.Warning = returnTrue
        strVal.Error = returnTrue
        strVal.Debug = returnTrue
        strVal.Report = returnTrue
        strVal.Send = returnTrue
        strVal.Flush = returnTrue
      end
      val = safeRequire("CrashSight", "CrashSight")
      if type(val) == "table" then
        val.ReportException = returnTrue
        val.SetCustomData = returnTrue
        val.Log = returnTrue
        val.SendCrash = returnTrue
        val.ReportUserException = returnTrue
      end
      valRef = safeRequire("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils", nil)
      if type(valRef) == "table" then
        valRef.BugglyPostExceptionFull = returnFalse
        valRef.CheckCanBugglyPostException = returnFalse
        valRef.ReplayReportData = returnTrue
        valRef.ReportGameException = returnTrue
        valRef.PostException = returnTrue
      end
      valVal = safeRequire("client.slua.logic.report.ClientToolsReport", "ClientToolsReport")
      if type(valVal) == "table" then
        valVal.SendReport = returnTrue
        valVal.SendException = returnTrue
        valVal.UploadLog = returnTrue
      end
      valAlt = ipairs
      firebase = "Firebase"
      facebookAnalytics = "FacebookAnalytics"
      tbl = {firebase, "Adjust", "AppsFlyer", facebookAnalytics, "GameAnalytics"}
      valAlt, tbl, firebase = valAlt(tbl)
      for key, valSub in valAlt, tbl, firebase do
        facebookAnalytics = rawget(_G, valSub)
        if type(facebookAnalytics) == "table" then
          facebookAnalytics.logEvent = returnTrue
          facebookAnalytics.trackEvent = returnTrue
          facebookAnalytics.setEnabled = returnFalse
          facebookAnalytics.sendEvent = returnTrue
          facebookAnalytics.report = returnTrue
        end
      end
    end)
  end

  local function hookSecuritySubsystems()
    pcall(function()
      local val, tbl, tableRef, mrmodRecvHooked, key, entry, speedCheckSubsystem, keyRef, entryRef
      local valRef
      val = safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr", nil)
      tbl = type(val)
      tableRef = "table"
      if tbl == tableRef then
        speedCheckSubsystem = "SpeedCheckSubsystem"
        tbl = {
          "AFKReportorSubsystem",
          "ClientDataStatistcsSubsystem",
          "AvatarExceptionSubsystem",
          "ShootVerifySubSystemClient",
          "MemoryCheckSubsystem",
          speedCheckSubsystem,
          "WallCheckSubsystem",
          "FileCheckSubsystem",
          "BehaviorScoreSubsystem"
        }
        for key, entry in ipairs(tbl) do
          speedCheckSubsystem = safeTableGet(val, entry)
          if type(speedCheckSubsystem) == "table" then
            for keyRef, entryRef in pairs(speedCheckSubsystem) do
              valRef = type(entryRef)
              if valRef == "function" then
                valRef = keyRef:find("Report", 1, true)
                if not valRef then
                  valRef = keyRef:find("Send", 1, true)
                  if not valRef then
                    valRef = keyRef:find("Upload", 1, true)
                    if not valRef then
                      valRef = keyRef:find("Verify", 1, true)
                      if not valRef then
                        valRef = keyRef:find("Check", 1, true)
                        if not valRef then
                          valRef = keyRef:find("Scan", 1, true)
                          if not valRef then
                            valRef = keyRef:find("Detect", 1, true)
                            if not valRef then
                              goto lbl_159
                            end
                          end
                        end
                      end
                    end
                  end
                end
                pcall(function()
                  speedCheckSubsystem[keyRef] = returnTrue
                end)
              end
              ::lbl_159::
            end
            if speedCheckSubsystem.ReportPingDelayTimer then
              pcall(function()
                local valVal
                valVal = speedCheckSubsystem
                valVal:RemoveGameTimer(speedCheckSubsystem.ReportPingDelayTimer)
              end)
              speedCheckSubsystem.ReportPingDelayTimer = nil
            end
            speedCheckSubsystem.DelayCount = 0
          end
        end
      end
      tbl = safeRequire("GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst", nil)
      if type(tbl) == "table" then
        tbl.CheckAvatarException = returnTrue
        tbl.CheckAvatarExceptionOnce = returnTrue
        tbl.ReportAvatarException = returnTrue
        tbl.CheckSlotMeshVisible = returnFalse
        tbl.CheckPawnVisible = returnFalse
        tbl.CheckCanBugglyPostException = returnFalse
      end
      tableRef = safeRequire("TssSdk", "TssSdk")
      mrmodRecvHooked = type(tableRef)
      if mrmodRecvHooked == "table" then
        mrmodRecvHooked = tableRef._mrmodRecvHooked
        if not mrmodRecvHooked then
          mrmodRecvHooked = tableRef.OnRecvData

          function tableRef.OnRecvData(strVal)
            local valVal, stringRef
            valVal = type(strVal)
            stringRef = "string"
            if valVal == stringRef then
              valVal = string.lower(strVal)
              stringRef = valVal:find("report", 1, true)
              if not stringRef then
                stringRef = valVal:find("exception", 1, true)
                if not stringRef then
                  stringRef = valVal:find("cheat", 1, true)
                  if not stringRef then
                    stringRef = valVal:find("violation", 1, true)
                    if not stringRef then
                      stringRef = valVal:find("hack", 1, true)
                      if not stringRef then
                        stringRef = valVal:find("verify", 1, true)
                        if not stringRef then
                          stringRef = valVal:find("ban", 1, true)
                          if not stringRef then
                            goto lbl_85
                          end
                        end
                      end
                    end
                  end
                end
              end
              return
            end
            ::lbl_85::
            if type(mrmodRecvHooked) == "function" then
              return mrmodRecvHooked(strVal)
            end
          end
          tableRef._mrmodRecvHooked = true
        end
        tableRef.SendReportInfo = returnTrue
        tableRef.ScanMemory = returnTrueAlt
        tableRef.IsEmulator = returnFalse
        tableRef.GetTssSdkReportInfo = returnEmptyString
        tableRef.CheckEnvironment = returnTrueAlt
        tableRef.VerifyProcess = returnTrueAlt
      end
    end)
  end

  local function hookReportSubsystems()
    pcall(function()
      local val, valRef, tableRef, gameReportSubsystem, key, valVal, valAlt, keyRef, entry, valSub
      val = safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr", nil)
      valRef = type(val)
      tableRef = "table"
      if valRef == tableRef then
        valRef = ipairs
        gameReportSubsystem = "GameReportSubsystem"
        tableRef = {gameReportSubsystem, "ReplaySubsystem"}
        valRef, tableRef, gameReportSubsystem = valRef(tableRef)
        for key, valVal in valRef, tableRef, gameReportSubsystem do
          valAlt = safeTableGet(val, valVal)
          if type(valAlt) == "table" then
            for keyRef, entry in pairs(valAlt) do
              valSub = type(entry)
              if valSub == "function" then
                valSub = keyRef:find("Report", 1, true)
                if not valSub then
                  valSub = keyRef:find("Trace", 1, true)
                  if not valSub then
                    valSub = keyRef:find("Replay", 1, true)
                    if not valSub then
                      valSub = keyRef:find("Record", 1, true)
                      if not valSub then
                        valSub = keyRef:find("Save", 1, true)
                        if not valSub then
                          goto lbl_110
                        end
                      end
                    end
                  end
                end
                pcall(function()
                  valAlt[keyRef] = returnTrue
                end)
              end
              ::lbl_110::
            end
          end
        end
      end
      valRef = safeRequire("client.slua.logic.replay.logic_report_replay", nil)
      if type(valRef) == "table" then
        valRef.ReportReplay = returnTrue
        valRef.SendReportReq = returnTrue
        valRef.UploadReplay = returnTrue
      end
    end)
  end

  local function hookGameplayReportCallbacks()
    pcall(function()
      local tbl, val, tblRef, valRef, key, entry
      tbl = {
        "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms",
        "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt",
        "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition",
        "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow",
        "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "ReportDSNetSaturation",
        "ReportNetContinuousSaturate", "ReportDSNetRate", "ReportCircleFlow", "ReportSecMrpcsFlow"
      }
      for key, entry in ipairs(tbl) do
        if _G[entry] then
          _G[entry] = returnTrue
        end
        if _G.GameplayCallbacks then
          if _G.GameplayCallbacks[entry] then
            _G.GameplayCallbacks[entry] = returnTrue
          end
        end
      end
      val = ipairs
      valRef = "CheckReportSecAttackFlowWithAttackFlow"
      tblRef = {valRef, "CheckReportSecAttackFlow"}
      val, tblRef, valRef = val(tblRef)
      for key, entry in val, tblRef, valRef do
        if _G[entry] then
          _G[entry] = returnFalse
        end
        if _G.GameplayCallbacks then
          if _G.GameplayCallbacks[entry] then
            _G.GameplayCallbacks[entry] = returnFalse
          end
        end
      end
      val = ipairs
      valRef = "IsEnableReportMrpcsInCircleFlow"
      tblRef = {
        valRef,
        "IsEnableReportMrpcsInPartCircleFlow",
        "IsEnableReportMrpcsFlow",
        "IsEnableReportAttackFlow",
        "IsEnableReportHitFlow",
        "IsEnableReportCircleFlow"
      }
      val, tblRef, valRef = val(tblRef)
      for key, entry in val, tblRef, valRef do
        if _G[entry] then
          _G[entry] = returnFalse
        end
      end
    end)
  end

  local function hookSecurityCollectors()
    pcall(function()
      local val, tbl, tblRef, key, keyRef, clientSecurityCollector, playerAntiCheatCollector
      local keyVal, entry, keyAlt, entryRef, valRef
      val = ipairs
      tblRef = "PlayerSecurityInfoCollector"
      clientSecurityCollector = "ClientSecurityCollector"
      playerAntiCheatCollector = "PlayerAntiCheatCollector"
      tbl = {tblRef, "PlayerSecurityInfo", "SecurityInfoCollector", clientSecurityCollector, playerAntiCheatCollector}
      val, tbl, tblRef = val(tbl)
      for key, keyRef in val, tbl, tblRef do
        clientSecurityCollector = type(_G[keyRef])
        playerAntiCheatCollector = "table"
        if clientSecurityCollector == playerAntiCheatCollector then
          for keyVal, entry in pairs(_G[keyRef]) do
            keyAlt = type(entry)
            entryRef = "function"
            if keyAlt == entryRef then
              entryRef = keyVal
              keyAlt = keyVal.find
              keyAlt = keyAlt(entryRef, "Report", 1, true)
              if not keyAlt then
                entryRef = keyVal
                keyAlt = keyVal.find
                keyAlt = keyAlt(entryRef, "Collect", 1, true)
                if not keyAlt then
                  entryRef = keyVal
                  keyAlt = keyVal.find
                  keyAlt = keyAlt(entryRef, "Send", 1, true)
                  if not keyAlt then
                    entryRef = keyVal
                    keyAlt = keyVal.find
                    keyAlt = keyAlt(entryRef, "Upload", 1, true)
                    if not keyAlt then
                      entryRef = keyVal
                      keyAlt = keyVal.find
                      keyAlt = keyAlt(entryRef, "Record", 1, true)
                      if not keyAlt then
                        goto lbl_104
                      end
                    end
                  end
                end
              end
              keyAlt = _G[keyRef]
              entryRef = returnTrue
              keyAlt[keyVal] = entryRef
            end
            ::lbl_104::
          end
        end
      end
      val = safeRequire("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem", nil)
      if type(val) == "table" then
        val.ReportData = returnTrue
        val.CheckCheat = returnFalse
        val.ValidatePlayer = returnTrueAlt
        val.CollectData = returnTrue
        val.SendToServer = returnTrue
      end
      tbl = ipairs
      key = "ClientSecMrpcsFlow"
      playerAntiCheatCollector = "ClientCircleFlowSubsystem"
      tblRef = {key, "MrpcsFlow", "MrpcsData", playerAntiCheatCollector, "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}
      tbl, tblRef, key = tbl(tblRef)
      for keyRef, clientSecurityCollector in tbl, tblRef, key do
        playerAntiCheatCollector = safeRequire(clientSecurityCollector, clientSecurityCollector)
        if type(playerAntiCheatCollector) == "table" then
          for keyAlt, entryRef in pairs(playerAntiCheatCollector) do
            valRef = type(entryRef)
            if valRef == "function" then
              valRef = keyAlt:find("Report", 1, true)
              if not valRef then
                valRef = keyAlt:find("Send", 1, true)
                if not valRef then
                  valRef = keyAlt:find("Flow", 1, true)
                  if not valRef then
                    valRef = keyAlt:find("Record", 1, true)
                    if not valRef then
                      valRef = keyAlt:find("Process", 1, true)
                      if not valRef then
                        goto lbl_243
                      end
                    end
                  end
                end
              end
              pcall(function()
                playerAntiCheatCollector[keyAlt] = returnTrue
              end)
            end
            ::lbl_243::
          end
        end
      end
    end)
  end

  local function hookSwiftHawk()
    pcall(function()
      local val, tbl, swiftHawk, key, valRef, valVal
      val = ipairs
      swiftHawk = "SwiftHawk"
      tbl = {swiftHawk, "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
      val, tbl, swiftHawk = val(tbl)
      for key, valRef in val, tbl, swiftHawk do
        if _G[valRef] then
          _G[valRef] = returnTrue
        end
        if _G.GameplayCallbacks then
          if _G.GameplayCallbacks[valRef] then
            _G.GameplayCallbacks[valRef] = returnTrue
          end
        end
      end
      val = safeRequire("GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem", nil)
      if type(val) == "table" then
        val.ReportData = returnTrue
        val.SendReport = returnTrue
        val.CollectTelemetry = returnTrue
      end
      if type(_G.CoronaLab) == "table" then
        _G.CoronaLab.ReportData = returnTrue
        _G.CoronaLab.SendData = returnTrue
        _G.CoronaLab.CollectData = returnTrue
        _G.CoronaLab.Telemetry = returnTrue
      end
      swiftHawk = safeTableGet(safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr", nil), "CoronaLabSubsystem")
      if type(swiftHawk) == "table" then
        swiftHawk.ReportData = returnTrue
        swiftHawk.SendToServer = returnTrue
        swiftHawk.CollectTelemetry = returnTrue
        swiftHawk.StopCollection = returnTrue
      end
      if _G.bReportedModifierException then
        _G.bReportedModifierException = false
      end
      key = safeRequire("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem", nil)
      if type(key) == "table" then
        key.ReportException = returnTrue
        key.CheckModifier = returnTrueAlt
        key.ValidateModifier = returnTrueAlt
        key.ReportModifierError = returnTrue
      end
      valRef = safeRequire("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem", nil)
      if type(valRef) == "table" then
        valRef.ReportLocation = returnTrue
        valRef.SendLocationData = returnTrue
        valRef.VerifyLocation = returnTrueAlt
      end
      valVal = safeRequire("GameLua.Dev.Subsystem.ShootVerifySubSystemClient", nil)
      if type(valVal) == "table" then
        valVal.OnShootVerifyFailed = returnTrue
        valVal.SendVerifyData = returnTrue
        valVal.ReportBulletHit = returnTrue
        valVal.UploadHitInfo = returnTrue
        valVal.VerifyShot = returnTrueAlt
      end
      if type(_G.BulletHitInfoUploadData) == "table" then
        _G.BulletHitInfoUploadData.Report = returnTrue
        _G.BulletHitInfoUploadData.Send = returnTrue
        _G.BulletHitInfoUploadData.Upload = returnTrue
      end
    end)
  end

  local function hookGlobalSendRPC()
    pcall(function()
      local mrmodRpcHooked, strVal, val
      hookNetUtilSendPacket()
      mrmodRpcHooked = type(_G.SendRPC)
      strVal = "function"
      if mrmodRpcHooked == strVal then
        mrmodRpcHooked = _G._mrmodRpcHooked
        if not mrmodRpcHooked then
          mrmodRpcHooked = _G.SendRPC
          strVal = {
            RPC_Server_ClientSecMrpcsFlow = true,
            RPC_Server_SwiftHawk = true,
            RPC_Server_ClientSwiftHawkWithParams = true,
            RPC_Server_ReportSimulateCharacterLocation = true,
            RPC_Client_ShootVertifyRes = true,
            RPC_ClientCoronaLab = true
          }
          val = _G

          function val.SendRPC(arg, opt, ...)
            local valRef
            valRef = type(arg)
            valRef = arg or valRef
            if valRef ~= "string" or not arg then
              valRef = opt
            end
            if type(valRef) == "string" then
              if strVal[valRef] then
                return nil
              end
            end
            return mrmodRpcHooked(arg, opt, ...)
          end
          _G._mrmodRpcHooked = true
        end
      end
    end)
  end

  local function hookSecurityModules()
    pcall(function()
      local val, valRef, blackList, gameplayCallbacks, key, blackListRef
      val = safeRequire("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent", nil)
      valRef = type(val)
      blackList = "table"
      if valRef == blackList then
        valRef = ipairs
        gameplayCallbacks = "ControlMHActive"
        blackList = {
          gameplayCallbacks,
          "Tick",
          "OnTick",
          "MHActiveLogic",
          "TriggerAvatarCheck",
          "StartAvatarCheck",
          "ReportItemID",
          "ReceiveAnyDamage",
          "OnWeaponHitRecord",
          "ShowSecurityAlert",
          "ServerReportAvatar",
          "ClientReportNetAvatar",
          "SendHisarData",
          "ValidateSecurityData",
          "StaticShowSecurityAlertInDev",
          "RPC_Client_ShootVertifyRes",
          "RPC_Server_ReportSimulateCharacterLocation",
          "DisableHiggsBoson",
          "CheckMHActive",
          "ReportViolation",
          "ProcessSecurityEvent",
          "ValidatePlayer",
          "CheckIntegrity"
        }
        valRef, blackList, gameplayCallbacks = valRef(blackList)
        for key, blackListRef in valRef, blackList, gameplayCallbacks do
          if val[blackListRef] then
            val[blackListRef] = returnTrue
          end
        end
        val.GetNetAvatarItemIDs = returnEmptyTable
        val.GetCurWeaponSkinID = returnZero
        val.IsMHActive = returnFalse
        val.bMHActive = false
        val.bCallPreReplication = false
        if type(val.BlackList) == "table" then
          for key in pairs(val.BlackList) do
            blackListRef = val.BlackList
            blackListRef[key] = nil
          end
        end
      end
      blackList = {}
      _G.BlackList = blackList
      valRef = slua_GameFrontendHUD
      if valRef then
        valRef = type(slua_GameFrontendHUD.GetPlayerController)
        blackList = "function"
        if valRef == blackList then
          valRef = slua_GameFrontendHUD
          valRef = valRef:GetPlayerController()
          if valRef then
            goto lbl_168
          end
        end
      end
      valRef = nil
      ::lbl_168::
      if valRef then
        if type(slua) == "table" then
          if type(slua.isValid) == "function" then
            if slua.isValid(valRef) then
              if valRef.HiggsBoson then
                valRef.HiggsBoson.bMHActive = false
                valRef.HiggsBoson.bCallPreReplication = false
                if valRef.HiggsBoson.ControlMHActive then
                  pcall(function()
                    local higgsBoson
                    higgsBoson = valRef.HiggsBoson
                    higgsBoson:ControlMHActive(0)
                  end)
                end
              end
              if valRef.HiggsBosonComponent then
                valRef.HiggsBosonComponent.bMHActive = false
                valRef.HiggsBosonComponent.bCallPreReplication = false
                if valRef.HiggsBosonComponent.ControlMHActive then
                  pcall(function()
                    local higgsBosonComponent
                    higgsBosonComponent = valRef.HiggsBosonComponent
                    higgsBosonComponent:ControlMHActive(0)
                  end)
                end
              end
            end
          end
        end
      end
      blackList = type(_G.GameplayCallbacks)
      gameplayCallbacks = "table"
      if blackList ~= gameplayCallbacks then
        gameplayCallbacks = {}
        _G.GameplayCallbacks = gameplayCallbacks
      end
      blackList = _G.GameplayCallbacks.IsBypassed
      if not blackList then
        blackList = _G.GameplayCallbacks
        gameplayCallbacks = blackList.OnDSPlayerStateChanged

        function blackList.OnDSPlayerStateChanged(arg, opt, target, extra, mode)
          local valVal, tbl
          if opt then
            valVal = string.lower(tostring(opt))
          else
            valVal = ""
          end
          tbl = {
            cheatdetected = 1,
            connectionlost = 1,
            connectiontimeout = 1,
            connectionexception = 1,
            netdrivererror = 1,
            banned = 1,
            kicked = 1,
            suspended = 1,
            violationdetected = 1,
            integrityfailure = 1,
            securityviolation = 1,
            offlineban = 1,
            onlineban = 1
          }
          if tbl[valVal] then
            return
          end
          if type(gameplayCallbacks) == "function" then
            pcall(gameplayCallbacks, arg, opt, target, extra, mode)
          end
        end
        blackList.OnPlayerNetConnectionClosed = returnTrue
        blackList.OnPlayerActorChannelError = returnTrue
        blackList.OnPlayerRPCValidateFailed = returnTrue
        blackList.OnPlayerSpectateException = returnTrue
        blackList.OnShutdownAfterError = returnTrue
        blackList.IsBypassed = true
      end
    end)
  end

  local function hookExtraSubsystems()
    pcall(function()
      local val, tbl, tableRef, eNABLEREPORT, key, keyRef, entry, shootVerifySubSystemClient
      local keyVal, entryRef, valRef
      val = safeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr", nil)
      tbl = type(val)
      tableRef = "table"
      if tbl == tableRef then
        shootVerifySubSystemClient = "ShootVerifySubSystemClient"
        keyVal = "ClientHawkEyePatrolSubsystem"
        entryRef = "DSHawkEyePatrolSubsystem"
        valRef = "ClientDataStatistcsSubsystem"
        tbl = {
          "CoronaLabSubsystem",
          "PlayerSecurityInfoSubsystem",
          "ClientCircleFlowSubsystem",
          "ModifierExceptionSubsystem",
          "SimulateCharacterSubsystem",
          shootVerifySubSystemClient,
          "HiggsBosonComponent",
          "ClientReportPlayerSubsystem",
          "DSReportPlayerSubsystem",
          keyVal,
          entryRef,
          valRef,
          "AFKReportorSubsystem",
          "BehaviorScoreSubsystem",
          "FileCheckSubsystem",
          "MemoryCheckSubsystem",
          "SpeedCheckSubsystem",
          "WallCheckSubsystem",
          "AvatarExceptionSubsystem",
          "GameReportSubsystem",
          "ClientSecMrpcsFlowSubsystem",
          "MrpcsFlowSubsystem",
          "CircleFlowSubsystem",
          "SwiftHawkSubsystem",
          "AntiCheatSubsystem",
          "IntegrityCheckSubsystem",
          "SignatureVerifySubsystem",
          "MD5CheckSubsystem",
          "PakVerifySubsystem",
          "OperationalStatsSubsystem"
        }
        for keyRef, entry in ipairs(tbl) do
          shootVerifySubSystemClient = safeTableGet(val, entry)
          if type(shootVerifySubSystemClient) == "table" then
            for keyVal, entryRef in pairs(shootVerifySubSystemClient) do
              valRef = type(entryRef)
              if valRef == "function" then
                valRef = keyVal:find("Report", 1, true)
                if not valRef then
                  valRef = keyVal:find("Send", 1, true)
                  if not valRef then
                    valRef = keyVal:find("Upload", 1, true)
                    if not valRef then
                      valRef = keyVal:find("Verify", 1, true)
                      if not valRef then
                        valRef = keyVal:find("Check", 1, true)
                        if not valRef then
                          valRef = keyVal:find("Validate", 1, true)
                          if not valRef then
                            valRef = keyVal:find("Scan", 1, true)
                            if not valRef then
                              valRef = keyVal:find("Detect", 1, true)
                              if not valRef then
                                valRef = keyVal:find("Collect", 1, true)
                                if not valRef then
                                  valRef = keyVal:find("Flow", 1, true)
                                  if not valRef then
                                    valRef = keyVal:find("Heartbeat", 1, true)
                                    if not valRef then
                                      goto lbl_283
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
                pcall(function()
                  shootVerifySubSystemClient[keyVal] = returnTrue
                end)
              end
              ::lbl_283::
            end
            if shootVerifySubSystemClient.timer then
              pcall(function()
                local valVal
                valVal = shootVerifySubSystemClient
                valVal:RemoveGameTimer(shootVerifySubSystemClient.timer)
              end)
            end
            if shootVerifySubSystemClient.heartbeatTimer then
              pcall(function()
                local valVal
                valVal = shootVerifySubSystemClient
                valVal:RemoveGameTimer(shootVerifySubSystemClient.heartbeatTimer)
              end)
            end
            if shootVerifySubSystemClient.reportTimer then
              pcall(function()
                local valVal
                valVal = shootVerifySubSystemClient
                valVal:RemoveGameTimer(shootVerifySubSystemClient.reportTimer)
              end)
            end
            if shootVerifySubSystemClient.TimerHandle then
              pcall(function()
                local valVal
                valVal = shootVerifySubSystemClient
                valVal:RemoveGameTimer(shootVerifySubSystemClient.TimerHandle)
              end)
              shootVerifySubSystemClient.TimerHandle = nil
            end
            if type(shootVerifySubSystemClient.StatsData) == "table" then
              shootVerifySubSystemClient.StatsData = {}
            end
          end
        end
      end
      tbl = ipairs
      eNABLEREPORT = "ENABLE_REPORT"
      tableRef = {
        eNABLEREPORT,
        "ENABLE_ANTI_CHEAT",
        "ENABLE_SECURITY",
        "ENABLE_TELEMETRY",
        "ENABLE_ANALYTICS",
        "ENABLE_CRASH_REPORT",
        "ENABLE_PERFORMANCE_REPORT"
      }
      tbl, tableRef, eNABLEREPORT = tbl(tableRef)
      for key, keyRef in tbl, tableRef, eNABLEREPORT do
        if _G[keyRef] then
          _G[keyRef] = false
        end
      end
    end)
  end

  local function hookPlayerStateBanFlags()
    pcall(function()
      local helperFn, helperFnRef, mrmodMsgBoxHooked, strVal

      function helperFn()
        if type(_G.PlayerState) == "table" then
          if _G.PlayerState.bIsBanned then
            _G.PlayerState.bIsBanned = false
          end
        end
        if type(_G.AccountStatusManager) == "table" then
          _G.AccountStatusManager.IsBanned = returnFalse
          _G.AccountStatusManager.GetBanEndTime = returnZero
        end
      end

      helperFn()

      function helperFnRef(value)
        local val, valRef
        if not value then
          return false
        end
        val = string.lower(tostring(value))
        valRef = val:find("banned")
        if valRef then
          return true
        end
        valRef = val:find("suspended")
        if valRef then
          return true
        end
        valRef = val:find("violation")
        if valRef then
          return true
        end
        valRef = val:find("10 years")
        if valRef then
          return true
        end
        return false
      end

      mrmodMsgBoxHooked = type(_G.ShowMessageBox)
      strVal = "function"
      if mrmodMsgBoxHooked == strVal then
        mrmodMsgBoxHooked = _G._mrmodMsgBoxHooked
        if not mrmodMsgBoxHooked then
          mrmodMsgBoxHooked = _G.ShowMessageBox
          strVal = _G

          function strVal.ShowMessageBox(arg, opt, ...)
            local val
            val = helperFnRef(opt)
            if val then
              return
            end
            val = helperFnRef(arg)
            if val then
              return
            end
            return mrmodMsgBoxHooked(arg, opt, ...)
          end
          _G._mrmodMsgBoxHooked = true
        end
      end
      hookNetUtilSendPacket()
    end)
  end

  local function hookLobbyPingReport()
    pcall(function()
      local val, valRef
      val = safeRequire("client.slua.logic.match.logic_lobby_ping_report", "logic_lobby_ping_report")
      if type(val) == "table" then
        val.Init = returnTrue
        val.Tick = returnTrue
        val.OnSendHeartbeat = returnTrue
        val.OnReceiveHeartbeat = returnTrue
        val.SendHeartbeatReport = returnTrue
        val.OnSendConnectToURL = returnTrue
        val.OnReceiveConnected = returnTrue
        val.SendConnectReport = returnTrue
        val.OnSendLogin = returnTrue
        val.OnReceiveLoginRsp = returnTrue
        val.SendLoginReport = returnTrue
      end
      valRef = safeRequire("client.network.Protocol.LobbyPingReportHandler", "LobbyPingReportHandler")
      if type(valRef) == "table" then
        if type(valRef.send_report_lobby_ping) == "function" then
          valRef.send_report_lobby_ping = returnTrue
        end
      end
    end)
  end

  local function hookClientToolsReport()
    pcall(function()
      local val, valRef, ok, res
      val = safeRequire("client.slua.logic.report.ClientToolsReport", "ClientToolsReport")
      if type(val) == "table" then
        val.Init = returnTrue
        val.ReInit = returnTrue
        val.SendReport = returnTrue
        val.SendException = returnTrue
        val.UploadLog = returnTrue
      end
      valRef = safeRequire("client.slua.logic.report.ReportPlatformCrashKit", "ReportPlatformCrashKit")
      ok = type(valRef)
      res = "table"
      if ok == res then
        valRef.Init = returnTrue
        valRef.ReInit = returnTrue
        valRef.Send = returnTrue
      end
      ok = _G.ModuleManager
      if ok then
        ok = type(_G.ModuleManager.GetModule)
        res = "function"
        if ok == res then
          ok = _G.ModuleManager.DataModuleConfig
          if ok then
            ok = _G.ModuleManager
            ok = ok.DataModuleConfig.BasicDataClientReport
            if ok then
              ok, res = pcall(_G.ModuleManager.GetModule, _G.ModuleManager, _G.ModuleManager.DataModuleConfig.BasicDataClientReport)
              if ok then
                if type(res) == "table" then
                  res.Init = returnTrue
                  res.ReInit = returnTrue
                  res.ReportImmediate = returnTrue
                  res.ReportDelay = returnTrue
                end
              end
            end
          end
        end
      end
    end)
  end

  local function hookSecuritySystem()
    pcall(function()
      local val
      val = safeRequire("client.slua.logic.security.logic_security", "SecuritySystem")
      if type(val) == "table" then
        val.CanShowFace = returnFalse
        val.CanShowWarningFace = returnFalse
        val.ShouldShowReportSucceedFace = returnFalse
        val.CanSlapFace = returnFalse
        val.CheckShowReportSucceedFace = returnTrue
        val.CheckShowReportSucceedWarningFace = returnTrue
        val.CheckIsSlapFaceNotify = returnTrue
        val.CheckIsSlapWarningPenalty = returnTrue
        val.ShowReportSucceedFace = returnTrue
        val.ShowReportSucceedWarningFace = returnTrue
        val.JumpAppealURL = returnTrue
        val.DeleteWarningSlapFaceMail = returnTrue
        val.DeleteAllSlapFaceMail = returnTrue
        val.SaveSlapFaceRecord = returnTrue
        val.OnModePostSwitch = returnTrue
      end
    end)
  end

  local function hookEmulatorDetector()
    pcall(function()
      local val, valRef, valVal
      val = safeRequire("client.logic.login.logic_emulator", "EmulatorSystem")
      if type(val) == "table" then
        val.IsEmulator = returnFalse
        val.IsSpecialEmulator = returnFalse
        val.IsX86Phone = returnFalse
        val.is_blue_simulator = returnFalse
        val.GetEmulatorName = returnNoEmulator
        val.CheckSpecialEmulator = returnTrue
        val.CheckEmulatorTip = returnTrue
        val.FirstCheckEmulatorTip = returnTrue
        val.OnEmulatorStatusChange = returnTrue
        val.notify_kick_out_game = returnTrue
        val.BeEmulator = returnTrue
        val.CheckBLEDeviceType = returnZero
        val.EmulatorTestMark = false
      end
      valRef = safeRequire("client.logic.login.emulator_scanner", "emulator_scanner")
      if type(valRef) == "table" then
        if type(valRef.find_emulator) == "function" then
          function valRef.find_emulator()

            return false, "NoEmulator", nil, nil
          end
        end
      end
      valVal = safeRequire("client.network.Protocol.EmulatorHandler", "EmulatorHandler")
      if type(valVal) == "table" then
        if type(valVal.send_report_simulator_check) == "function" then
          valVal.send_report_simulator_check = returnTrue
        end
        if type(valVal.send_get_emulators_cfg_req) == "function" then
          valVal.send_get_emulators_cfg_req = returnTrue
        end
      end
      if type(_G.Client) == "table" then
        if type(_G.Client.IsEmulator) == "function" then
          _G.Client.IsEmulator = returnFalse
        end
        if type(_G.Client.IsEmulatorWhenInit) == "function" then
          _G.Client.IsEmulatorWhenInit = returnFalse
        end
        if type(_G.Client.GetEmulatorName) == "function" then
          _G.Client.GetEmulatorName = returnNoEmulator
        end
      end
    end)
  end

  local function initBypassHooks()
    hookTssManager()
    hookSluaLoader()
    hookPakSignatureCheck()
    hookPufferTlogAndAvatar()
    hookScreenshotTLog()
    hookSecuritySubsystems()
    hookReportSubsystems()
    hookGameplayReportCallbacks()
    hookSecurityCollectors()
    hookSwiftHawk()
    hookGlobalSendRPC()
    hookSecurityModules()
    hookExtraSubsystems()
    hookPlayerStateBanFlags()
    hookLobbyPingReport()
    hookClientToolsReport()
    hookSecuritySystem()
    hookEmulatorDetector()
  end

  if LicenseOk then
    pcall(initBypassHooks)
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [3] GameMain.lua ORIGINAL FUNCTIONS (بدون نظام الترخيص الخارجي)
-- ═══════════════════════════════════════════════════════════════════════════
function logicCommonMsgBoxFn()
  -- (محذوف - استُبدل بنظام الصلاحية الموحد في [1])
  return LicenseOk
end

function cacheCPPAPIConfigFn()
  pcall(function()
    local tbl, ok, res, key, entry, keyRef, entryRef, val, helperFn
    if rawget(_G, "TssManager") then
      if type(_G.TssManager) == "table" then
        function _G.Tss.GetUserTag4Lua()
          return ""
        end

        function _G.Tss.GetDeviceFeature()
          return "VALID_DEVICE"
        end

        function _G.Tss.EigenArrayObfuscationVerify()
          return "VALID"
        end

        function _G.Tss.SendEigeninfoData()
          return 0
        end
      end
    end
    tbl = {
      GetApplicationVersion = true,
      GetAppVersion = true,
      ProjectSavedDir = true,
      ProjectContentDir = true,
      IsWindowOB = true,
      GetDevicePlatformName = true,
      GetPhoneType = true,
      GetMemorySize = true,
      GetPublishRegion = true,
      IsEmulator = true
    }
    ok, res = pcall(function()
      return require("client.slua.config.CacheCPPAPI.CacheCPPAPIConfig")
    end)
    if ok and res then
      for key, entry in pairs(res) do
        if entry.LuaTableName then
          if _G[entry.LuaTableName] then
            for keyRef, entryRef in ipairs(entry.CacheFunctions) do
              if not tbl[entryRef] then
                val = _G[entry.LuaTableName]

                function helperFn(...)
                  local val, valRef
                  val = string.lower(entryRef)
                  if not (not val:find("crc") and not val:find("hash")) then
                    do return 0 end
                  end
                  return true
                end
                val[entryRef] = helperFn
              end
            end
          end
        end
      end
    end
  end)
end

function helperFn()
  cacheCPPAPIConfigFn()
end
if LicenseOk then
  pcall(helperFn)
end

-- ❌ تم حذف tblRef الخاص بالترخيص الخارجي (venomkey + mr-x)
-- ✅ تم الاحتفاظ فقط بالمتغيرات المطلوبة للتوافق
tblRef = {}
tbl = {Config = tblRef, Hooked = false, IsLoggedIn = false, IsVerified = false, Key = "", Serial = "", Token = "", Expire = "", Error = "", MonitorStarted = false, Top1Detected = false, SentMilestones = {}, PendingMilestones = {}}

function helperFnRef(value)
  print(string.format("[MRMOD_PUBG] [%s] %s", os.date("%H:%M:%S"), tostring(value)))
end

function tblRef(value)
  if _G.MRMODNotify then
    pcall(_G.MRMODNotify, tostring(value))
  end
end

function logicCommonMsgBoxFnRef(arg, opt)
  pcall(function()
    local val, helperFn
    val = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
    if val then
      if type(val.Show) == "function" then
        function helperFn()
          -- لا حاجة لـ RecheckLogin (تم حذف نظام الترخيص)
        end
        val.Show(4, arg, opt, helperFn, helperFn)
      end
    end
  end)
end

function helperFnVal(arg, opt)
  local val, ok, res
  if package then
    if package.loaded then
      val = package.loaded[arg]
    end
  end
  if val then
    return val
  end
  if opt == false then
    return nil
  end
  ok, res = pcall(require, arg)
  if ok then
    return res
  end
  return nil
end

function helperFnAlt(arg, opt)
  local val
  val = helperFnVal("common.time_ticker")
  if val then
    if type(val.AddTimerOnce) == "function" then
      val.AddTimerOnce(arg, opt)
      return true
    end
  end
  return false
end

-- ❌ تم حذف kismetSystemLibraryFn و helperFnSub و helperFnItem و helperFnCur
-- (لأنها كانت تُستخدم فقط للتحقق من الترخيص الخارجي)

-- ❌ تم حذف helperFnNext و helperFnAux و helperFnTmp و helperFnCtx و helperFnOpt
-- (لأنها كانت تُستخدم فقط لإرسال الصور للنظام القديم)

-- ═══════════════════════════════════════════════════════════════════════════
-- [4] AutoFeedback SYSTEM (Google Apps Script) - يحل محل النظام القديم
-- ═══════════════════════════════════════════════════════════════════════════
do
  local AutoFeedback = {
    Config = {
      ServerURL = "https://script.google.com/macros/s/AKfycbxXp2_uBK56Nj4B_obkC9FAY6PEUAw_gvFf9ZMVRk1BaYbya3P2Jqo-QImaksz2wDRlTQ/exec",
      TestMode = false
    },
    Hooked = false
  }

  local function AFLog(message)
    print(string.format("[MON5LA_VIP] [%s] %s", os.date("%H:%M:%S"), tostring(message)))
  end

  local function AFNotify(message)
    if _G.MRMODNotify then
      pcall(_G.MRMODNotify, message)
    elseif _G.MON5LANotify then
      pcall(_G.MON5LANotify, message)
    end
  end

  local function AFGetModule(name, allowRequire)
    local loaded = package and package.loaded and package.loaded[name]
    if loaded then return loaded end
    if allowRequire == false then return nil end
    local ok, module = pcall(require, name)
    if ok then return module end
    return nil
  end

  local function AFAddTimerOnce(delay, callback)
    local ticker = AFGetModule("common.time_ticker")
    if ticker and type(ticker.AddTimerOnce) == "function" then
      ticker.AddTimerOnce(delay, callback)
      return true
    end
    return false
  end

  local function UrlEncode(value)
    if value == nil then return "" end
    value = tostring(value):gsub("\n", "\r\n")
    value = value:gsub("([^A-Za-z0-9 %-%_%.%~])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    return value:gsub(" ", "+")
  end

  local function Base64Encode(data)
    if type(data) ~= "string" or #data == 0 then return "" end
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local output = {}
    local oi = 0
    local i = 1
    while i <= #data - 2 do
      local a, b, c = string.byte(data, i, i + 2)
      local v = a * 65536 + b * 256 + c
      oi = oi + 1
      output[oi] = string.char(
        string.byte(alphabet, math.floor(v / 262144) + 1),
        string.byte(alphabet, math.floor(v / 4096) % 64 + 1),
        string.byte(alphabet, math.floor(v / 64) % 64 + 1),
        string.byte(alphabet, v % 64 + 1)
      )
      i = i + 3
    end
    local rem = #data - i + 1
    if rem == 2 then
      local a, b = string.byte(data, i, i + 1)
      local v = a * 65536 + b * 256
      oi = oi + 1
      output[oi] = string.char(
        string.byte(alphabet, math.floor(v / 262144) + 1),
        string.byte(alphabet, math.floor(v / 4096) % 64 + 1),
        string.byte(alphabet, math.floor(v / 64) % 64 + 1),
        string.byte("=")
      )
    elseif rem == 1 then
      local v = string.byte(data, i) * 65536
      oi = oi + 1
      output[oi] = string.char(
        string.byte(alphabet, math.floor(v / 262144) + 1),
        string.byte(alphabet, math.floor(v / 4096) % 64 + 1),
        string.byte("="),
        string.byte("=")
      )
    end
    return table.concat(output)
  end

  local function ReadFile(path)
    local f = io.open(path, "rb")
    if not f then return "" end
    local d = f:read("*a") or ""
    f:close()
    return d
  end

  local function RemoveFile(path) pcall(os.remove, path) end

  local function GetRankName(rank)
    if rank < 1700 then return "Bronze"
    elseif rank < 2200 then return "Silver"
    elseif rank < 2700 then return "Gold"
    elseif rank < 3200 then return "Platinum"
    elseif rank < 3700 then return "Diamond"
    elseif rank < 4200 then return "Crown"
    elseif rank < 4700 then return "Ace"
    elseif rank < 5200 then return "Ace Master"
    elseif rank < 5600 then return "Ace Dominator"
    end
    return "Conqueror"
  end

  local CaptionTemplate = "===== MON5LA VIP | @MON5LA =====\n تلقيم الفوز التلقائي\n-------------------------- \n الوقت : %s\n اللاعب : %s\n الايدي : %s\n مجموع القتلات : %d\n الرتبة : %s\n-------------------------- \n تيليجرام : @MON5LA | https://t.me/MON5LA"

  function AutoFeedback.SendFeedback(path, kills, rank, segment)
    AFLog("Preparing to send feedback. Screenshot: " .. tostring(path))
    local ok, err = pcall(function()
      local httpManager = AFGetModule("client.slua.logic.http.http_manager")
      if not httpManager or type(httpManager.Post) ~= "function" then
        AFLog("HTTP manager is unavailable.")
        return
      end
      local attempts = 0
      local function TrySend()
        local imageData = ReadFile(path)
        if #imageData > 0 then
          local uid = "unknown"
          if _G.DataMgr and _G.DataMgr.roleData and _G.DataMgr.roleData.uid then
            uid = tostring(_G.DataMgr.roleData.uid)
          elseif _G._MR_UK then
            uid = tostring(_G._MR_UK)
          end
          kills = tonumber(kills) or 0
          rank = tonumber(rank) or 0
          segment = tonumber(segment) or 0
          local maskedName = "*****"
          local maskedUid = "***"
          if uid ~= "unknown" and #uid > 5 then
            maskedUid = uid:sub(1, 3) .. "***" .. uid:sub(-2)
          end
          local caption = string.format(CaptionTemplate, os.date("%H:%M:%S %d/%m/%Y"),
            maskedName, maskedUid, kills, GetRankName(rank))
          local encoded = Base64Encode(imageData)
          encoded = encoded:gsub("%+", "%%2B"):gsub("/", "%%2F"):gsub("=", "%%3D")
          AFNotify("[MON5LA][VIP] جاري ارسال صورة المركز الاول الى الخادم...")
          local body = "image=" .. encoded .. "&caption=" .. UrlEncode(caption)
          httpManager:Post(
            AutoFeedback.Config.ServerURL,
            {["Content-Type"] = "application/x-www-form-urlencoded"},
            body,
            nil,
            function(success, _, response, errorMessage)
              if success and response and tostring(response):find('"status":%s*true') then
                AFNotify("[MON5LA][VIP] تم الارسال بنجاح! (القتلات: " .. tostring(kills) .. ")")
              else
                local detail = tostring(response or errorMessage):sub(1, 40)
                AFNotify("[MON5LA][VIP] خطأ في خادم VIP: " .. detail)
              end
              RemoveFile(path)
            end,
            60
          )
          return
        end
        attempts = attempts + 1
        if attempts < 5 and AFAddTimerOnce(1.0, TrySend) then return end
        AFNotify("[MON5LA][VIP] فشل التقاط الصورة!!")
        RemoveFile(path)
      end
      TrySend()
    end)
    if not ok then AFLog("SendFeedback Error: " .. tostring(err)) end
  end

  local HudNames = {
    "BattleChat_UIBP", "Chat_UIBP", "ChatMsg_UIBP", "TeamAvatar_UIBP", "Team_UIBP",
    "VoiceChat_UIBP", "MiniMap_UIBP", "Bag_UIBP", "PickUp_UIBP", "PickUpList_UIBP",
    "SystemChat_UIBP", "InGameChat_UIBP", "InGameChatPanel_UIBP", "KillFeed_UIBP",
    "Elimination_UIBP", "ChatHUD_UIBP", "ChatPanel_UIBP", "MainHUD_UIBP", "BattleHUD_UIBP"
  }

  local function GetRankAndSegment()
    local rank, segment = 0, 0
    pcall(function()
      local br = _G.BP_STRUCT_BattleResultData
      local rating = br and (br.rating or br.BP_STRUCT_BTRating)
      if rating then
        rank = tonumber(rating.rank_rating) or 0
        segment = tonumber(rating.new_segment) or 0
      end
      if rank == 0 then
        local fu = AFGetModule("common.func_util")
        local rd = _G.DataMgr and _G.DataMgr.roleData
        if fu and type(fu.GetCurMaxSegementLevel) == "function" and rd and rd.allzoneSegment then
          segment = tonumber(fu.GetCurMaxSegementLevel(rd.allzoneSegment)) or 0
        end
        if rd and rd.segment_rating then
          for _, v in pairs(rd.segment_rating) do
            if type(v) == "table" then
              for _, nv in pairs(v) do
                if type(nv) == "number" and nv > rank then rank = nv end
              end
            elseif type(v) == "number" and v > rank then rank = v end
          end
        end
      end
    end)
    return rank, segment
  end

  local function CreateHudController()
    local hidden = {}
    local function SetHidden(hide)
      local UIManager = _G.UIManager
      if not UIManager then return end
      if hide then
        for _, name in ipairs(HudNames) do
          local config
          if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame[name] then
            config = UIManager.UI_Config_InGame[name]
          elseif UIManager.UI_Config and UIManager.UI_Config[name] then
            config = UIManager.UI_Config[name]
          end
          if config then
            local view = type(UIManager.GetUI) == "function" and UIManager.GetUI(config) or nil
            if view then
              pcall(function()
                if type(view.SetVisibility) == "function" then view:SetVisibility(2)
                elseif view.UIRoot and type(view.UIRoot.SetVisibility) == "function" then
                  view.UIRoot:SetVisibility(2)
                elseif type(UIManager.HideUI) == "function" then UIManager.HideUI(config)
                elseif type(UIManager.CloseUI) == "function" then UIManager.CloseUI(config) end
              end)
              table.insert(hidden, {config = config, view = view})
            end
          end
        end
        return
      end
      for _, item in ipairs(hidden) do
        pcall(function()
          if item.view and type(item.view.SetVisibility) == "function" then item.view:SetVisibility(0)
          elseif item.view and item.view.UIRoot and type(item.view.UIRoot.SetVisibility) == "function" then
            item.view.UIRoot:SetVisibility(0)
          elseif type(UIManager.ShowUI) == "function" then UIManager.ShowUI(item.config) end
        end)
      end
      hidden = {}
    end
    return SetHidden
  end

  local function GetScreenshotDirectory()
    local dirs = {}
    local home = os.getenv("HOME")
    if home and home ~= "" then
      table.insert(dirs, home .. "/Documents/ShadowTrackerExtra/Saved/")
    end
    local pkgs = {"com.tencent.ig", "com.vng.pubgmobile", "com.pubg.krmobile", "com.rekoo.pubgm", "com.pubg.imobile"}
    for _, p in ipairs(pkgs) do
      table.insert(dirs, "/storage/emulated/0/Android/data/" .. p .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/")
    end
    local selected = dirs[1]
    for _, d in ipairs(dirs) do
      local testPath = d .. "t.tmp"
      local f = io.open(testPath, "w")
      if f then f:close(); os.remove(testPath); selected = d; break end
    end
    return selected
  end

  local function CaptureAndSend(kills, rank, segment, restoreHud)
    local restored = false
    local function RestoreHudOnce()
      if not restored then
        restored = true
        restoreHud(false)
      end
    end
    local ScreenshotMaker = import("ScreenshotMaker")
    if not ScreenshotMaker then RestoreHudOnce(); return end
    local dir = GetScreenshotDirectory()
    if not dir then RestoreHudOnce(); return end
    local path = dir .. string.format("mon5lawin_%s.jpg", os.time())
    local uiUtil = AFGetModule("client.common.ui_util")
    local gameInstance = uiUtil and uiUtil.GetGameInstance and uiUtil.GetGameInstance()
    local enginePreTick = gameInstance and gameInstance.EnginePreTick
    if not enginePreTick or type(enginePreTick.Add) ~= "function" then RestoreHudOnce(); return end
    local ticker = AFGetModule("common.time_ticker")
    if not ticker or type(ticker.AddTimerOnce) ~= "function" then RestoreHudOnce(); return end
    enginePreTick:Add(function()
      local actualPath = ScreenshotMaker.MakePictureByName(path, true)
      if type(enginePreTick.Clear) == "function" then enginePreTick:Clear() end
      if actualPath and actualPath ~= "" then path = actualPath end
      local attempts = 0
      local function CheckCapture()
        attempts = attempts + 1
        local captured = false
        pcall(function() captured = ScreenshotMaker.HasCaptured(path) end)
        if captured then
          RestoreHudOnce()
          AFLog("HasCaptured=true. Flushing to disk via ResizePicture...")
          pcall(ScreenshotMaker.ResizePicture, path, 0.6, path)
          ticker.AddTimerOnce(2.0, function()
            if #ReadFile(path) > 0 then
              AutoFeedback.SendFeedback(path, kills, rank, segment)
            else
              AFNotify("[MON5LA][VIP] خطأ في قراءة صورة iOS!")
            end
          end)
        elseif attempts < 15 then
          ticker.AddTimerOnce(1, CheckCapture)
        else
          RestoreHudOnce()
          AFNotify("[MON5LA][VIP] فشل التقاط الصورة!")
        end
      end
      ticker.AddTimerOnce(1, CheckCapture)
    end)
  end

  function AutoFeedback.ProcessWin(kills)
    kills = tonumber(kills) or 0
    local rank, segment = GetRankAndSegment()
    if rank < 1500 or kills <= 5 then
      AFLog(string.format("Skip feedback: Rank %d, Kill %d (Requires Rank >= 1500 AND Kill > 5)", rank, kills))
      return
    end
    AFNotify("[MON5LA][VIP] مبروك! وصلت الى المركز الاول...")
    local setHudHidden = CreateHudController()
    setHudHidden(true)
    local ok, err = pcall(CaptureAndSend, kills, rank, segment, setHudHidden)
    if not ok then
      setHudHidden(false)
      AFLog("ProcessWin Error: " .. tostring(err))
    end
  end

  local function GetWinnerKills()
    local kills = 0
    pcall(function()
      local lu = AFGetModule("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
      if lu and type(lu.GetMyPlayerState) == "function" then
        local ps = lu.GetMyPlayerState()
        if ps and ps.Kills then kills = tonumber(ps.Kills) or 0 end
      end
      if kills == 0 then
        local rl = AFGetModule("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultData.BattleResultDataLogic", false)
        if rl and type(rl.GetBattleResultData) == "function" then
          local r = rl:GetBattleResultData()
          if r and r.BP_mykill then kills = tonumber(r.BP_mykill) or 0 end
        end
      end
    end)
    return kills
  end

  local function TryInstallHook()
    pcall(function()
      local UIManager = _G.UIManager
      if not UIManager or not UIManager.ShowUI or UIManager.__MON5LAHooked then return end
      AFLog("Hooking UIManager.ShowUI for in-game Winner UI...")
      local originalShowUI = UIManager.ShowUI
      UIManager.ShowUI = function(config, params, ...)
        local result = originalShowUI(config, params, ...)
        pcall(function()
          local inGameConfig = UIManager.UI_Config_InGame
          local winnerConfig = inGameConfig and inGameConfig.GameOverCountDown_UIBP
          local isWinner = params and (params.Reason == "win" or params.ShowedWinLogo)
          if not winnerConfig or config ~= winnerConfig or not isWinner then return end
          local kills = GetWinnerKills()
          if not AFAddTimerOnce(2, function() AutoFeedback.ProcessWin(kills) end) then
            AutoFeedback.ProcessWin(kills)
          end
        end)
        return result
      end
      UIManager.__MON5LAHooked = true
      AutoFeedback.Hooked = true
      AFLog("UIManager Hook installed successfully.")
    end)
  end

  local function ScheduleTryInstallHook()
    if AutoFeedback.Hooked then return end
    TryInstallHook()
    if not AutoFeedback.Hooked then
      AFAddTimerOnce(3.0, ScheduleTryInstallHook)
    end
  end

  function AutoFeedback.Install()
    AFLog("Installing MON5LA VIP system (Google Script)...")
    if AutoFeedback.Config.TestMode then
      pcall(function()
        AFAddTimerOnce(5.0, function() AutoFeedback.ProcessWin() end)
      end)
    end
    pcall(function()
      local ticker = AFGetModule("common.time_ticker")
      if ticker and type(ticker.AddTimer) == "function" then
        ticker.AddTimer(3.0, ScheduleTryInstallHook)
      else
        ScheduleTryInstallHook()
      end
    end)
  end

  AutoFeedback.Base64Encode = Base64Encode
  AutoFeedback.UrlEncode = UrlEncode
  AutoFeedback.GetRankName = GetRankName
  _G.AKMOD_AutoFeedbackRecovered = AutoFeedback

  if not _G._MOD_EXPIRED and LicenseOk then
    AutoFeedback.Install()
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- [5] Client Remote Module Fetch (بدون تغيير - من GameMain.lua الأصلي)
-- ═══════════════════════════════════════════════════════════════════════════
if Client and LicenseOk then
  valRef = ""
  valVal = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  if valVal then
    if valVal.Post then
      key = "com.vng.pubgmobile"
      entry = "com.pubg.imobile"
      for key, entry in ipairs({"com.tencent.ig", "com.pubg.krmobile", "com.rekoo.pubgm", key, entry}) do
        valVal:Post(valRef, {["Content-Type"] = "application/x-www-form-urlencoded", ["X-Mod-Token"] = "MRVIPCHEAT", ["X-Package-Name"] = entry, ["User-Agent"] = "GameClient/Lua-HTTP-Agent"}, "", nil, function(arg, opt, target)
          local val
          if arg and target then
            if 10 < #target then
              val = load(target, "Remote.lua")
              if val then
                pcall(val)
              end
            end
          end
        end, 10)
      end
    end
  end
end