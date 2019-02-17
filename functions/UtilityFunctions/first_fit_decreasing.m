% u: a vector of activity indices
% C: capacity of each bin
function wffd = first_fit_decreasing(u, C)

n = length(u);
r = C*ones(1,n);    % Residuals
w = zeros(n);       % assignment matrix. w(i,j)= 1 if u(i) is assigned to b(j)

[ud1,idec] = sort(-u);    % sort obj. in decreasing size order
ud=-ud1;
[~,irec] = sort(idec);  % irec is the recovery ordering

wffd=w; rffd=r; % initialize for first fit method
for j=1:n,
   % disp(['ud(' int2str(i) ') = ' int2str(ud(i))]);
   % disp('r = '); disp(rffd);
   idx=find(ud(j)*ones(1,n)<=rffd, 1);
   % disp(['u(' int2str(i) ') is assigned to b(' int2str(idx) ');']);
   wffd(j,idx)=1;
   rffd(idx)=rffd(idx)-ud(j);  % update the state
   % disp('Press any key to continue ...'); pause
end
wffd=wffd(irec,:); % sort it back to the original assignment order