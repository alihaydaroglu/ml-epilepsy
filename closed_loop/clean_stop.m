function clean_stop(mea, stg)
    mea.StopDacq();
    mea.Disconnect();
    fclose(stg);
    delete(stg);
end