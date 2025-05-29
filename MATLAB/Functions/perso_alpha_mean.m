function mean_alpha = perso_alpha_mean(alpha, env, f_min, f_max)
    mask = @(env) (env.w / (2*pi) > f_min & env.w / (2*pi) < f_max);
    mean_alpha = mean(alpha(mask(env)));
end