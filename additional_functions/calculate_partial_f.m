function [FSTAT,pvalue,beta_full,beta_p,beta_t]=calculate_partial_f(new_X,new_X_reduced,y,fast)

FSTAT=[];
pvalue=[];
beta_full=[];
beta_p=[];
beta_t=[];

%%%%%Calcoliamo i beta del modello intero
beta_full = ((new_X'*new_X)^-1)*new_X'*y; % Coefficients
%%%%%Calcoliamo i residui
residual_full=y-(new_X*beta_full);

if(fast==0)
%%%%%Calcoliamo SSE e MSE
SSE = sum(residual_full.^2); % Sum of squares error
MSE = SSE/(numel(y)-numel(beta_full)); % Residuals' mean squared error
%%%%%Calcoliamo il T dei coeff del full
SE_beta_full = sqrt(diag(MSE*(new_X'*new_X)^-1)); % Coefficients' standard error
t = beta_full./SE_beta_full; % T-values of coefficients
beta_t = t;
beta_p = 2.*(1-tcdf(abs(t),numel(y)-numel(beta_full))); % p-values of coefficients
end

%%%%%Adesso facciamo il fitting del modello ridotto
beta_reduced = ((new_X_reduced'*new_X_reduced)^-1)*new_X_reduced'*y; % Coefficients
residual_reduced=y-(new_X_reduced*beta_reduced);

FSTAT_SSR=sum(residual_reduced.^2);
FSTAT_SSF=sum(residual_full.^2);
FSTAT_NUM=(FSTAT_SSR-FSTAT_SSF)/(numel(beta_full)-numel(beta_reduced));
FSTAT_DEN=FSTAT_SSF/(numel(y)-numel(beta_full));
FSTAT=FSTAT_NUM./FSTAT_DEN;

pvalue=fcdf(1/FSTAT,  (numel(y)-numel(beta_full)), numel(beta_reduced));

end
