classdef Soilder
properties
      ID ;
      blood ;
      live_time ;
      birth_day ;
      death_day ;
      past_life;
      born_health;
      first_wound;
end
properties (Dependent)
Modulus
end
methods
    
       function obj = Soilder(health)
            obj.ID = 0;
            obj.blood =0;
            obj.live_time = 0;
            obj.birth_day = 0;
            obj.death_day = 0;
            obj.past_life=[];
            obj.born_health = floor(health);
            obj.first_wound=0;
       end
        
      function obj = reborn(obj, id, birth_day )
          if obj.blood > 0
              printf("he is still alive!");
              return ;
          end
          obj.ID = id;
          obj.blood = obj.born_health ;
          obj.birth_day =  birth_day;
          obj.live_time = 0;
          obj.death_day = 0;

      end
      
     function obj = fulfill(obj)
         if obj.blood < 0
              printf("he is dead and can be cured!")
              return ;
          end
         obj.blood = obj.born_health;
     end
     
     function obj = over(obj, time)
         if obj.blood > 0
             obj.death_day = time;
             obj.live_time =  obj.death_day  -  obj.birth_day ;
             obj.past_life = [obj.past_life; [obj.birth_day, obj.death_day, obj.live_time]];
         end      
     end
     
      function obj =fight(obj, time)
          if obj.blood < 0
              printf("he is dead and can fight!")
              return ;
          end
         obj.blood = obj.blood -1;
         if (obj.blood == 0)
             obj.death_day = time;
             obj.live_time =  obj.first_wound -  obj.birth_day ;
             obj.past_life = [obj.past_life; [obj.birth_day,  obj.first_wound, obj.live_time  ]];
         end
         if (obj.blood == obj.born_health -1)
             obj.first_wound = time - 1;
         end
      end
      
      function state = die(obj)
           if(obj.blood > 0)
               state= 0;
           else
               state= 1;
           end
          
      end
   end
end