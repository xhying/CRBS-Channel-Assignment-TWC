function I = solve_MIS(mode, M)
%fprintf('\n------------------ Solving MIS with %s --------------------\n', mode);

if strcmp(mode, 'gurobi')
    % Use Gurobi to solve the ILP problem (Maximum Independent Set)
    var_cnt = length(M(1, :));

    names = cell(var_cnt, 1);
    sense = '';

    for i = 1:var_cnt
        names{i} = sprintf('x%d', i);
        sense = [sense, '<'];
    end

    w = ones(1, var_cnt);
    M = M;
    rhs = ones(var_cnt, 1);

    try
        clear model;
        model.A = sparse(M);
        model.obj = w;
        model.rhs = rhs;
        model.sense = sense;
        model.vtype = 'B';
        model.modelsense = 'max';
        model.varnames = names;

        gurobi_write(model, 'mis_test.lp');

        clear params;
        params.outputflag = 0;

        result = gurobi(model, params);

        disp(result)

        disp(find(result.x'==1))

    %     for v=1:length(names)
    %         fprintf('%s %d\n', names{v}, result.x(v));
    %     end

        fprintf('Obj: %e\n', result.objval);
        
    catch gurobiError
        fprintf('Error reported\n');
    end
    
    I = find(result.x'==1);
    
elseif strcmp(mode, 'intlinprog')
    var_cnt = length(M(1, :));
    
    f = -1 * ones(var_cnt, 1);
    intcon = 1:1:var_cnt;   % ALl take integer values

    A = M; 
    b = ones(var_cnt, 1);

    lb = zeros(var_cnt,1);
    ub = ones(var_cnt,1);

    x = intlinprog(f,intcon,A,b,[],[],lb,ub);
    I = find(x == 1);
    
elseif strcmp(mode, 'greedy')
    I = zeros(1, length(M(1, :)));
    V = 1:length(M(1, :));     % Set of all vertices

    while ~isempty(V)
        best_vertex = [];
        max_value = 0;
        for i = 1:length(V)
            v = V(i);
            % The denominator is # of conflicting neighbors of v in V
            % (including v itself).
            value = 1/(sum(M(v, V)));
            if value > max_value
                best_vertex = v;
            end
        end

        I(best_vertex) = 1;
        V = setdiff(V, [best_vertex, find(M(best_vertex,:))]);
    end

    I = sort(find(I==1));
else
    error('Unknown mode');
end

% Check if it is a valid solution
conflict_flag = 0;

for i = 1:length(I)
    for j = (i+1):length(I)
        if M(I(i), I(j)) == 1
            conflict_flag = 1;
        end
    end
end

if conflict_flag ~= 0
    error('\t Error in MIS: there exists conflict in I\n');
end
