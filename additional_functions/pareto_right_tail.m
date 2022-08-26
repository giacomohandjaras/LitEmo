function [pvalue,critical_value_at_p]=pareto_right_tail(null_distro,critical_value,critical_p)

tail_to_model=0.90;
draw_plot=0;
debug=0;
options = statset('MaxIter',500, 'MaxFunEvals',1000,'TolBnd',1.0000e-06,'TolFun',1.0000e-06,'TolX',1.0000e-06);

pvalue=[];
critical_value_at_p=nan(1,1);

permutations=numel(null_distro);

q = prctile(null_distro,tail_to_model*100);

right_tail = null_distro(null_distro>q) - q;
effect_eps=range(right_tail)/(permutations/numel(right_tail));

paramEsts = gpfit(right_tail,options);
kHat      = paramEsts(1);   % Tail index parameter
sigmaHat  = paramEsts(2);   % Scale parameter

if(kHat>-0.5)

if draw_plot==1
figure(); hold on;
bins = min(right_tail):range(right_tail)/10:max(right_tail);
h = bar(bins,histc(right_tail,bins)/(length(right_tail)*range(right_tail)/10),'histc');
h.FaceColor = [.9 .9 .9];
right_tail_grid = linspace(min(right_tail),1.5*max(right_tail),100);
line(right_tail_grid,gppdf(right_tail_grid,kHat,sigmaHat));
xlim([min([min(right_tail),critical_value-q]),max([1.5*max(right_tail),critical_value-q])]);
plot([critical_value-q,critical_value-q], [0,gppdf(0,kHat,sigmaHat)],'--','Color',[0,0,0], 'LineWidth', 1);
xlabel('Exceedance');
ylabel('Probability Density');
end


%%%%If we are in the tail....
if(critical_value-q)>0

estimated_cum=gpcdf(critical_value-q,kHat,sigmaHat);
pvalue=1-(tail_to_model+(estimated_cum*(1-tail_to_model)));

if (pvalue<eps/2)
if(debug>0);disp(sprintf('Pvalue is in the tail of interst but it is too small, below the resolution of double...'));end
bins=0:effect_eps:(critical_value-q);
pvalue_emp=nan(numel(bins),1);
for test=1:numel(bins)
estimated_cum=gpcdf(bins(test),kHat,sigmaHat);
pvalue=1-(tail_to_model+(estimated_cum*(1-tail_to_model)));
pvalue_emp(test)=pvalue;
end
good_pvalues=find(pvalue_emp>0);
pvalue=pvalue_emp(good_pvalues(end));
end

%%%%we are not in the right tail
else
if(debug>0); disp(sprintf('Pvalue is in the wrong tail...'));end
null_distro=cat(1,null_distro(:),critical_value(:));
null_distro_sort=sort(null_distro,'descend');
position=find(null_distro_sort==critical_value);
pvalue=position(1)/(permutations+1);
end


else %kHat<-0.05
null_distro=cat(1,null_distro(:),critical_value(:));
null_distro_sort=sort(null_distro,'descend');
position=find(null_distro_sort==critical_value);
pvalue=position(1)/(permutations+1);
if(debug>0); disp(sprintf('The parameter KHat is too low for Pareto, hence I will mantain the current shallow p-val of %.6f',pvalue));end
end



%%%%Evaluate the critical_value_at_p
if(debug>0); disp(sprintf('Evaluate the Pareto approximation of pvalue...'));end

bins=0:effect_eps/10:5*max(right_tail);
pvalue_emp=nan(numel(bins),1);
for test=1:numel(bins)
estimated_cum=gpcdf(bins(test),kHat,sigmaHat);
pvalue_temp=1-(tail_to_model+(estimated_cum*(1-tail_to_model)));
pvalue_emp(test)=pvalue_temp;
end

for test=1:numel(bins)
if pvalue_emp(test)>critical_p
critical_value_at_p=bins(test)+q;
end
end


end
