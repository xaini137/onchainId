import { database } from '../firebase';
import { ref, set, push, onValue } from "firebase/database";
import React, { useState } from 'react'
import { useEffect } from 'react';


export default function Topic() {
    const [topics , setTopics] = useState([]);
    const [topic, setTopic] = useState('');

    useEffect(() => {

        const saveTopicToFirebase = () => {
            const topicsRef = ref(database, 'topics');
            const newTopicRef = push(topicsRef);
            set(newTopicRef, topic).then(() => {
              alert('Topic saved successfully');
              setTopic('');
            }).catch((error) => {
              alert('Failed to save topic: ' + error.message);
            });
          };


      const topicsRef = ref(database , 'topics');
      console.log(topicsRef);
      onValue(topicsRef, (snapshot) => {
        const data = snapshot.val();
        if (data) {
          setTopics(Object.entries(data).map(([key, value]) => ({ key, value })));
      console.log(topics);
      
        }
      });
    
   
    }, [])
    

    const handleTopicInputChange = (e) => {
        setTopic(e.target.value);
      };




      const saveTopicToFirebase = () => {
        const topicsRef = ref(database, 'topics');
        const newTopicRef = push(topicsRef);
        set(newTopicRef, topic).then(() => {
          alert('Topic saved successfully');
          setTopic('');
        }).catch((error) => {
          alert('Failed to save topic: ' + error.message);
        });
      };
    


  return (<>
    <h2>Topic</h2>

    <div className="input-group">
            <label className="label">Add Topic</label>
         
              <input
                type="text"
                name="topic"
                placeholder="Enter a topic"
                value={topic}
                onChange={handleTopicInputChange}
              />
              <button onClick={saveTopicToFirebase}>Save Topic</button>
        
          </div>
    <div className="input-group">
            <label className="label">Select Topic</label>
            <select>
              <option value="">Select a topic</option>
              {topics.map((topic) => (
                <option key={topic.key} value={topic.value}>{topic.value}</option>
              ))}
            </select>
          </div> 
    </>
  )
}
