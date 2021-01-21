using Crux, Flux, POMDPGym, Random, POMDPs

expert_buffer_size = 1000

## Cartpole - V0 (For DQN-GAIL)
mdp = GymPOMDP(:CartPole, version = :v0)
as = actions(mdp)
S = state_space(mdp)

Q() = Chain(Dense(dim(S)..., 64, relu), Dense(64, 64, relu), Dense(64, length(as)))
D_PG() = DeterministicNetwork(Chain(Dense(dim(S)[1] + length(as), 64, relu), Dense(64, 64, relu), Dense(64, 1, sigmoid)))
D_DQN() = DQNPolicy(Chain(Dense(dim(S)..., 64, relu), Dense(64, 64, relu), Dense(64, length(as), sigmoid)), as)
V() = Chain(Dense(dim(S)..., 64, relu), Dense(64, 64, relu), Dense(64, 1))
A() = Chain(Dense(dim(S)..., 64, relu), Dense(64, 64, relu), Dense(64, length(as)), softmax)

# Solve with DQN
𝒮_dqn = DQNSolver(π = DQNPolicy(Q(), as), S = S, N=20000)
π_dqn = solve(𝒮_dqn, mdp)

# Fill a buffer with expert trajectories
expert_trajectories = ExperienceBuffer(steps!(Sampler(mdp = mdp, S = S, A = action_space(π_dqn), π = π_dqn), Nsteps = expert_buffer_size))
sum(expert_trajectories[:r])


# Solve with DQN-GAIL
𝒮_gail = GAILSolver(D = D_DQN(), 
                    G = DQNSolver(π = DQNPolicy(Q(), as), S = S, N=30000),
                    expert_buffer = expert_trajectories)
solve(𝒮_gail, mdp)

# Solve with PPO-GAIL
𝒮_ppo = PGSolver(π = ActorCritic(CategoricalPolicy(A(), as), V()), 
                S = S, N=30000, ΔN = 500, loss = ppo())
𝒮_gail = GAILSolver(D = D_PG(), 
                    G = 𝒮_ppo,
                    expert_buffer = expert_trajectories)
solve(𝒮_gail, mdp)

