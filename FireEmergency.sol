// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLevelContract {

    enum LevelType {
        Level1,
        Level2,
        Level3,
        Level4
    }

    enum StepType {
        CallChief,
        TriggerAlarm,
        ExtinguishFire,
        Escape
    }

    struct Level {
        LevelType levelType;
        uint256 mark;
        uint256 time;
    }

    struct Player {
        Level[] levels;
        address pk;
        mapping(LevelType => uint256) currentStepIndex; // Track current step index for each level
        mapping(LevelType => uint256[]) marks; // Auxiliar structure to track marks for each level
    }

    mapping(LevelType => StepType[]) levelSteps;
    mapping(address => Player) public players;

    // Function to set steps for a specific level
    function setLevelSteps(LevelType levelType, StepType[] memory steps) public {
        levelSteps[levelType] = steps;
    }

    function isLevelCompleted(LevelType levelType) public view returns (bool) {
        for (uint256 i = 0; i < players[msg.sender].levels.length; i++) {
            if (players[msg.sender].levels[i].levelType == levelType) {
                return true;
            }
        }
        return false;
    }

    // Function to generate a random score (for demonstration purposes)
    function getRandomScore() private view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, msg.sender)
            )
        ) % 101; // Generate a random number between 0 and 100
        return randomNumber;
    }

    function performStep(LevelType levelType, StepType currentStep) public {
        bool stepFound;
        uint256 currentIndex;
        uint256 randomMark;

        require(!isLevelCompleted(levelType), "Level already completed");

        Player storage player = players[msg.sender];

        // Get the current step index for the level
        currentIndex = player.currentStepIndex[levelType];

        // Check if the performed step matches the required step
        if (levelSteps[levelType][currentIndex] == currentStep) {
            stepFound = true;

            // Increment current step index for the level
            player.currentStepIndex[levelType]++;

            // Random mark (development)
            randomMark = getRandomScore();
            player.marks[levelType].push(randomMark);
        }

        require(stepFound, "Incorrect step performed");

        // If all steps are completed
        if (currentIndex == levelSteps[levelType].length - 1) {
            uint256 totalMarks = 0;
            for (uint256 i = 0; i < player.marks[levelType].length; i++) {
                totalMarks += player.marks[levelType][i];
            }
            uint256 averageMark = totalMarks / player.marks[levelType].length;
            player.levels.push(Level(levelType, averageMark, block.timestamp));

            // Reset current step index and marks for the completed level
            //delete player.marks[levelType];
            //player.currentStepIndex[levelType] = 0;
        }
    }
}