import { database } from '../firebase';
import { ref, set, push, onValue } from "firebase/database";
import React, { useState, useEffect } from 'react';

export default function Topic() {
    const [topics, setTopics] = useState([]);
    const [topic, setTopic] = useState('');
    const [hexcode, setHexcode] = useState('');

    useEffect(() => {
        const topicsRef = ref(database, 'topics');
        onValue(topicsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                setTopics(Object.entries(data).map(([key, value]) => ({ key, value })));
            }
        });
    }, []);

    const handleTopicInputChange = (e) => {
        setTopic(e.target.value);
    };

    const handleHexcodeInputChange = (e) => {
        setHexcode(e.target.value);
    };

    const saveTopicToFirebase = () => {
        const topicsRef = ref(database, 'topics');
        const newTopicRef = push(topicsRef);
        const topicData = {
            topic: topic,
            hexcode: hexcode
        };
        set(newTopicRef, topicData)
            .then(() => {
                alert('Topic saved successfully');
                setTopic('');
                setHexcode('');
            })
            .catch((error) => {
                alert('Failed to save topic: ' + error.message);
            });
    };

    return (
        <>
            <h2>Topic</h2>

            <div className="input-group">
           
                <label className="label">Add Topic</label>
                <input
                    type="text"
                    placeholder="Enter a topic"
                    value={topic}
                    onChange={handleTopicInputChange}
                />
                <input
                    type="text"
                    placeholder="Enter hex code"
                    value={hexcode}
                    onChange={handleHexcodeInputChange}
                />
                <button onClick={saveTopicToFirebase}>Save Topic</button>
            </div>

            <div className="input-group">
                <label className="label">Select Topic</label>
                <select>
                    <option value="">Select a topic</option>
                    {topics.map((topic) => (
                        <option key={topic.key} value={topic.value.hexcode}>
                            {topic.value.topic}
                        </option>
                    ))}
                </select>
            </div>
        </>
    );
}
