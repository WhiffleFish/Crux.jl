using CUDA
CUDA.allowscalar(false)
include("util_tests.jl")
include("experience_buffer_tests.jl")
include("sampler_tests.jl")
include("policy_tests.jl")
include("logging_tests.jl")
include("multitask_learning_tests.jl")
include("solver_tests/dqn_tests.jl")
include("solver_tests/actor_critic_tests.jl")
include("solver_tests/gail_tests.jl")
include("solver_tests/ddpg_tests.jl")

