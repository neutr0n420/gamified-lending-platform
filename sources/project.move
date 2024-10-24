module LearningPlatform::GamifiedLearning {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    // Error codes
    const E_NOT_REGISTERED: u64 = 1;
    const E_ALREADY_REGISTERED: u64 = 2;
    const E_INSUFFICIENT_POINTS: u64 = 3;

    /// Struct representing a learner's profile
    struct LearnerProfile has key {
        points: u64,           // Learning points earned
        courses_completed: u64, // Number of courses completed
        last_reward: u64,      // Timestamp of last reward claim
        total_rewards: u64     // Total rewards earned
    }

    /// Function to initialize a learner's profile
    public entry fun create_learner_profile(
        account: &signer
    ) {
        let addr = signer::address_of(account);
        assert!(!exists<LearnerProfile>(addr), E_ALREADY_REGISTERED);
        
        let profile = LearnerProfile {
            points: 0,
            courses_completed: 0,
            last_reward: timestamp::now_seconds(),
            total_rewards: 0
        };
        move_to(account, profile);
    }

    /// Function to complete a course and earn rewards
    public entry fun complete_course(
        learner: &signer,
        points_earned: u64,
        reward_amount: u64
    ) acquires LearnerProfile {
        let addr = signer::address_of(learner);
        let profile = borrow_global_mut<LearnerProfile>(addr);
        
        profile.points = profile.points + points_earned;
        profile.courses_completed = profile.courses_completed + 1;
        profile.last_reward = timestamp::now_seconds();
        profile.total_rewards = profile.total_rewards + reward_amount;
        
        coin::transfer<AptosCoin>(@platform_treasury, addr, reward_amount);
    }
}