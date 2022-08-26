function [results_time_raw,results_time]=getdata_ngram_viewer_google(data_selected,data_time,temporal_windows)

perctile_window=10;
smoothing_filter=0.8;
steps=perctile_window*0.20;


results_time=nan(size(temporal_windows,2),1);

for i=1:size(temporal_windows,2)
temporal_mask=data_time>=temporal_windows(1,i) & data_time<=temporal_windows(2,i);
temp=data_selected(find(temporal_mask));
results_time(i)=nanmean(temp);
end

results_time_raw=results_time;

if (smoothing_filter>0)
temp_results_time=fit([1:numel(results_time)]',results_time,'smoothingspline','SmoothingParam',smoothing_filter);
results_time=temp_results_time([1:numel(results_time)]');
end

