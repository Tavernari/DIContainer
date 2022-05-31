//
//  File.swift
//  
//
//  Created by Victor C Tavernari on 31/05/2022.
//

import Foundation

struct BadStruct {
    
    init(param1: String, param2: String, param3: String, param4: String, param5: String) {
        param1.forEach { char1 in
            param2.forEach { char2 in
                
                if char1 == char1 {
                    
                    param3.forEach { char3 in
                        
                        if char1 == char3 {
                            
                            param4.forEach { char4 in
                                print( char4 )
                            }
                            
                        } else  {
                            
                            param5.forEach { char5 in
                                print(char5)
                            }
                        }
                    }
                }
            }
        }
    }
}
