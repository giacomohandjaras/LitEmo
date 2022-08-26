function [results_time_raw,results_time,results_time_up,results_time_down,temporal_windows]=getdata_ngram_viewer(data_selected,authors_year)

perctile_window=10;
smoothing_filter=0.8;
steps=perctile_window*0.20;
bootstraps=1000;

temporal_windows=[];
rank_range=[0:steps:100-perctile_window];
for i=1:numel(rank_range)
temporal_windows(1,i)=prctile(authors_year,rank_range(i));
temporal_windows(2,i)=prctile(authors_year,rank_range(i)+perctile_window);
end

temporal_windows(1,1)=min(authors_year)-eps;
temporal_windows(2,end)=max(authors_year)+eps;

data_time=authors_year;

results_time=nan(size(temporal_windows,2),1);
results_time_up=nan(size(temporal_windows,2),1);
results_time_down=nan(size(temporal_windows,2),1);

for i=1:size(temporal_windows,2)
temporal_mask=data_time>=temporal_windows(1,i) & data_time<=temporal_windows(2,i);
temp=data_selected(temporal_mask);
results_time(i)=nanmean(temp);
if(bootstraps>0)
bootstraps_mean=bootstrp(bootstraps,@nanmean,temp);
results_time_up(i)=prctile(bootstraps_mean,97.5);
results_time_down(i)=prctile(bootstraps_mean,2.5);
end
end

results_time_raw=results_time;

if (smoothing_filter>0)
temp_results_time_up=fit([1:numel(results_time_up)]',results_time_up,'smoothingspline','SmoothingParam',smoothing_filter);
results_time_up=temp_results_time_up([1:numel(results_time_up)]');

temp_results_time_down=fit([1:numel(results_time_down)]',results_time_down,'smoothingspline','SmoothingParam',smoothing_filter);
results_time_down=temp_results_time_down([1:numel(results_time_down)]');

temp_results_time=fit([1:numel(results_time)]',results_time,'smoothingspline','SmoothingParam',smoothing_filter);
results_time=temp_results_time([1:numel(results_time)]');

end

